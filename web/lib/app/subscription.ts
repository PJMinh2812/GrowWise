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

/** Active plan name + its max_children limit (free → 1). */
export async function getActivePlan(): Promise<ActivePlan> {
  const supabase = await createServerSupabase()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { name: 'free', maxChildren: 1 }

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

export const FREE_LIMITS = {
  dailyAiMessages: 5,
  activeTasks: 3,
  lessons: 3,
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
