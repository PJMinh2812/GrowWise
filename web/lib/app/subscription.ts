import { createServerSupabase } from '@/lib/supabase-server'

export type PlanName = 'free' | 'premium' | 'family'

/** Active plan name for the logged-in user ('free' if none/expired). */
export async function getUserPlan(): Promise<PlanName> {
  const supabase = await createServerSupabase()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return 'free'
  const { data } = await supabase
    .from('user_subscriptions')
    .select('status, plan:plans(name)')
    .eq('user_id', user.id)
    .maybeSingle()
  if (!data) return 'free'
  const status = data.status as string
  if (status === 'active' || status === 'trial') {
    const planField = data.plan as unknown
    const name = Array.isArray(planField)
      ? (planField[0] as { name?: PlanName } | undefined)?.name
      : (planField as { name?: PlanName } | null)?.name
    return name ?? 'free'
  }
  return 'free'
}

export function isPremiumPlan(plan: PlanName): boolean {
  return plan === 'premium' || plan === 'family'
}

export interface ActivePlan {
  name: PlanName
  maxChildren: number
}

/**
 * If a scheduled plan change (downgrade) is due — i.e. the current period has
 * ended and `scheduled_plan_name` is set — switch the subscription to that plan
 * and start a fresh period. Best-effort & resilient: silently no-ops if the
 * `scheduled_plan_name` column doesn't exist yet (migration not applied).
 */
async function applyDueScheduledChange(userId: string): Promise<void> {
  const supabase = await createServerSupabase()
  const { data: row, error } = await supabase
    .from('user_subscriptions')
    .select('id, current_period_end, scheduled_plan_name')
    .eq('user_id', userId)
    .maybeSingle()
  if (error || !row) return
  const scheduled = (row as { scheduled_plan_name?: string | null }).scheduled_plan_name
  const periodEnd = (row as { current_period_end?: string | null }).current_period_end
  if (!scheduled || !periodEnd) return
  if (new Date(periodEnd) > new Date()) return // not due yet

  const { data: plan } = await supabase
    .from('plans')
    .select('id')
    .eq('name', scheduled)
    .maybeSingle()
  if (!plan) return

  const now = new Date()
  const end = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000)
  await supabase
    .from('user_subscriptions')
    .update({
      plan_id: (plan as { id: string }).id,
      status: 'active',
      current_period_start: now.toISOString(),
      current_period_end: end.toISOString(),
      scheduled_plan_name: null,
    })
    .eq('id', (row as { id: string }).id)
}

/** Active plan name + its max_children limit (free → 1). */
export async function getActivePlan(): Promise<ActivePlan> {
  const supabase = await createServerSupabase()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { name: 'free', maxChildren: 1 }

  await applyDueScheduledChange(user.id)

  const { data } = await supabase
    .from('user_subscriptions')
    .select('status, plan:plans(name, max_children)')
    .eq('user_id', user.id)
    .maybeSingle()

  if (!data) return { name: 'free', maxChildren: 1 }
  const status = data.status as string
  if (status !== 'active' && status !== 'trial') return { name: 'free', maxChildren: 1 }

  const planField = data.plan as unknown
  const plan = Array.isArray(planField)
    ? (planField[0] as { name?: PlanName; max_children?: number } | undefined)
    : (planField as { name?: PlanName; max_children?: number } | null)

  return {
    name: plan?.name ?? 'free',
    maxChildren: plan?.max_children ?? 1,
  }
}

export interface SubscriptionDetails extends ActivePlan {
  periodEnd: string | null
  scheduledPlan: PlanName | null
}

/** Active plan plus period end + any scheduled (downgrade) plan change. */
export async function getSubscriptionDetails(): Promise<SubscriptionDetails> {
  const active = await getActivePlan() // applies any due scheduled change
  const supabase = await createServerSupabase()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { ...active, periodEnd: null, scheduledPlan: null }

  const { data, error } = await supabase
    .from('user_subscriptions')
    .select('current_period_end, scheduled_plan_name')
    .eq('user_id', user.id)
    .maybeSingle()
  if (error || !data) return { ...active, periodEnd: null, scheduledPlan: null }

  return {
    ...active,
    periodEnd: (data as { current_period_end?: string | null }).current_period_end ?? null,
    scheduledPlan:
      ((data as { scheduled_plan_name?: PlanName | null }).scheduled_plan_name as PlanName | null) ??
      null,
  }
}

export const FREE_LIMITS = {
  dailyAiMessages: 5,
  activeTasks: 3,
  lessons: 3,
}

/** Daily emotion check-in limit per plan (Infinity = unlimited). */
export const EMOTION_LIMITS: Record<PlanName, number> = {
  free: 1,
  premium: 3,
  family: Infinity,
}

/** Today's emotion check-in count for the user. */
export async function getDailyEmotionUsage(userId: string): Promise<number> {
  const supabase = await createServerSupabase()
  const today = new Date().toISOString().slice(0, 10)
  const { data } = await supabase
    .from('daily_emotion_usage')
    .select('count')
    .eq('user_id', userId)
    .eq('date', today)
    .maybeSingle()
  return (data?.count as number) ?? 0
}

/** Increment today's emotion usage (upsert). */
export async function incrementEmotionUsage(userId: string): Promise<void> {
  const supabase = await createServerSupabase()
  const today = new Date().toISOString().slice(0, 10)
  const current = await getDailyEmotionUsage(userId)
  await supabase
    .from('daily_emotion_usage')
    .upsert(
      { user_id: userId, date: today, count: current + 1 },
      { onConflict: 'user_id,date' },
    )
}

/** Today's AI message count for the user. */
export async function getDailyAiUsage(userId: string): Promise<number> {
  const supabase = await createServerSupabase()
  const today = new Date().toISOString().slice(0, 10)
  const { data } = await supabase
    .from('daily_ai_usage')
    .select('message_count')
    .eq('user_id', userId)
    .eq('date', today)
    .maybeSingle()
  return (data?.message_count as number) ?? 0
}

/** Increment today's AI usage (upsert). */
export async function incrementAiUsage(userId: string): Promise<void> {
  const supabase = await createServerSupabase()
  const today = new Date().toISOString().slice(0, 10)
  const current = await getDailyAiUsage(userId)
  await supabase
    .from('daily_ai_usage')
    .upsert(
      { user_id: userId, date: today, message_count: current + 1 },
      { onConflict: 'user_id,date' },
    )
}
