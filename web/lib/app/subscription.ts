import { createServerSupabase } from '@/lib/supabase-server'
import { getCurrentUser } from '@/lib/app/auth'

export type PlanName = 'free' | 'premium' | 'family'

/** Active plan name for the logged-in user ('free' if none/expired). */
export async function getUserPlan(): Promise<PlanName> {
  const user = await getCurrentUser()
  if (!user) return 'free'
  const supabase = await createServerSupabase()
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
 * Apply any due change when the current period has ended:
 *  - if a scheduled plan change (downgrade) is set → switch to that plan and
 *    start a fresh period;
 *  - otherwise the subscription simply lapses → mark it `expired` (access then
 *    falls back to free; the user must pay again to renew — SePay is a one-time
 *    transfer with no auto-renew).
 * Best-effort & resilient: silently no-ops if the `scheduled_plan_name` column
 * doesn't exist yet (migration not applied).
 */
async function applyDuePeriodEnd(userId: string): Promise<void> {
  const supabase = await createServerSupabase()
  const { data: row, error } = await supabase
    .from('user_subscriptions')
    .select('id, status, current_period_end, trial_ends_at, scheduled_plan_name')
    .eq('user_id', userId)
    .maybeSingle()
  if (error || !row) return

  const status = (row as { status?: string }).status
  if (status !== 'active' && status !== 'trial') return

  const scheduled = (row as { scheduled_plan_name?: string | null }).scheduled_plan_name
  const periodEnd = (row as { current_period_end?: string | null }).current_period_end
  const trialEnd = (row as { trial_ends_at?: string | null }).trial_ends_at
  const deadline = status === 'trial' ? (trialEnd ?? periodEnd) : periodEnd
  if (!deadline) return
  if (new Date(deadline) > new Date()) return // not due yet

  const id = (row as { id: string }).id

  if (scheduled) {
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
      .eq('id', id)
    return
  }

  // No scheduled change → the paid/trial period lapsed.
  await supabase
    .from('user_subscriptions')
    .update({ status: 'expired' })
    .eq('id', id)
}

/** Active plan name + its max_children limit (free → 1). */
export async function getActivePlan(): Promise<ActivePlan> {
  const user = await getCurrentUser()
  if (!user) return { name: 'free', maxChildren: 1 }

  await applyDuePeriodEnd(user.id)
  const supabase = await createServerSupabase()

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
  const user = await getCurrentUser()
  if (!user) return { ...active, periodEnd: null, scheduledPlan: null }

  const supabase = await createServerSupabase()
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

export type RenewalState = 'none' | 'active' | 'expiring' | 'expired'

export interface RenewalInfo {
  state: RenewalState
  planName: PlanName
  displayName: string
  periodEnd: string | null
  daysLeft: number
}

/** Days from now until [iso], rounded up (>=0). */
function daysUntil(iso: string): number {
  const ms = new Date(iso).getTime() - Date.now()
  return Math.max(0, Math.ceil(ms / (24 * 60 * 60 * 1000)))
}

/**
 * Renewal banner state for the logged-in user. Calls getActivePlan() first so
 * any due expiry is applied, then reads the subscription row directly (we still
 * want the plan even when it has just been marked `expired`).
 *  - 'expired'  : a paid plan whose period ended (now downgraded to free)
 *  - 'expiring' : a paid plan with <= 7 days left
 *  - 'active'   : a paid plan with plenty of time left
 *  - 'none'     : free / no subscription
 */
export async function getRenewalState(): Promise<RenewalInfo> {
  await getActivePlan() // applies any due expiry first
  const user = await getCurrentUser()
  const empty: RenewalInfo = { state: 'none', planName: 'free', displayName: '', periodEnd: null, daysLeft: 0 }
  if (!user) return empty

  const supabase = await createServerSupabase()
  const { data, error } = await supabase
    .from('user_subscriptions')
    .select('status, current_period_end, plan:plans(name, display_name)')
    .eq('user_id', user.id)
    .maybeSingle()
  if (error || !data) return empty

  const status = (data as { status?: string }).status
  const periodEnd = (data as { current_period_end?: string | null }).current_period_end ?? null
  const planField = data.plan as unknown
  const plan = Array.isArray(planField)
    ? (planField[0] as { name?: PlanName; display_name?: string } | undefined)
    : (planField as { name?: PlanName; display_name?: string } | null)
  const planName = plan?.name ?? 'free'
  const displayName = plan?.display_name ?? ''

  if (planName === 'free') return empty

  if (status === 'expired') {
    return { state: 'expired', planName, displayName, periodEnd, daysLeft: 0 }
  }
  if ((status === 'active' || status === 'trial') && periodEnd) {
    const daysLeft = daysUntil(periodEnd)
    return {
      state: daysLeft <= 7 ? 'expiring' : 'active',
      planName,
      displayName,
      periodEnd,
      daysLeft,
    }
  }
  return empty
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
