'use server'

import { createServerSupabase } from '@/lib/supabase-server'
import { revalidatePath } from 'next/cache'
import type { PlanName } from './subscription'

type Result = { ok: boolean; error?: string }

/**
 * Schedule a plan downgrade that takes effect at the end of the current period
 * (e.g. family → premium). Stores `scheduled_plan_name`; the switch is applied
 * lazily by `applyDuePeriodEnd` once the period ends.
 */
export async function scheduleDowngrade(planName: PlanName): Promise<Result> {
  const supabase = await createServerSupabase()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { ok: false, error: 'unauthorized' }

  const { error } = await supabase
    .from('user_subscriptions')
    .update({ scheduled_plan_name: planName })
    .eq('user_id', user.id)
  if (error) return { ok: false, error: error.message }

  revalidatePath('/parent/settings')
  revalidatePath('/parent/pricing')
  return { ok: true }
}

/** Cancel a previously scheduled plan change. */
export async function cancelScheduledChange(): Promise<Result> {
  const supabase = await createServerSupabase()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { ok: false, error: 'unauthorized' }

  const { error } = await supabase
    .from('user_subscriptions')
    .update({ scheduled_plan_name: null })
    .eq('user_id', user.id)
  if (error) return { ok: false, error: error.message }

  revalidatePath('/parent/settings')
  revalidatePath('/parent/pricing')
  return { ok: true }
}
