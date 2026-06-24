import type { SupabaseClient } from '@supabase/supabase-js'
import type { Child } from '@/lib/types'

/** Split an amount into the 3 jars: save 40%, share 20%, spend the rest. */
export function splitJars(amount: number) {
  const toSave = Math.round(amount * 0.4)
  const toShare = Math.round(amount * 0.2)
  const toSpend = amount - toSave - toShare
  return { toSave, toShare, toSpend }
}

/**
 * Credit `amount` coins to a child, auto-splitting across the 3 jars, and log an
 * income row. Used by the day-end auto-approve (cron) and the parent's early
 * confirm of an auto-approve task. Works with any Supabase client (admin/server).
 */
export async function splitAndCreditJars(
  supabase: SupabaseClient,
  child: Child,
  amount: number,
  note: string,
) {
  if (amount <= 0) return
  const { toSave, toShare, toSpend } = splitJars(amount)
  await supabase
    .from('children')
    .update({
      total_coins: child.total_coins + amount,
      save_jar: child.save_jar + toSave,
      share_jar: child.share_jar + toShare,
      spend_jar: child.spend_jar + toSpend,
      updated_at: new Date().toISOString(),
    })
    .eq('id', child.id)

  await supabase.from('child_transactions').insert({
    child_id: child.id,
    type: 'income',
    amount,
    note,
  })
}

/**
 * Deduct a penalty from a child, taking from spend → save → share, and log an
 * expense row. Used by the day-end "missed task" penalty.
 */
export async function deductPenalty(
  supabase: SupabaseClient,
  child: Child,
  amount: number,
  note: string,
) {
  if (amount <= 0 || child.total_coins <= 0) return
  const take = Math.min(amount, child.total_coins)
  const fromSpend = Math.min(take, child.spend_jar)
  const fromSave = Math.min(take - fromSpend, child.save_jar)
  const fromShare = Math.min(take - fromSpend - fromSave, child.share_jar)

  await supabase
    .from('children')
    .update({
      total_coins: Math.max(0, child.total_coins - take),
      spend_jar: child.spend_jar - fromSpend,
      save_jar: child.save_jar - fromSave,
      share_jar: child.share_jar - fromShare,
      updated_at: new Date().toISOString(),
    })
    .eq('id', child.id)

  await supabase.from('child_transactions').insert({
    child_id: child.id,
    type: 'expense',
    amount: take,
    note,
  })
}
