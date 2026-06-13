'use server'

import { revalidatePath } from 'next/cache'
import { createServerSupabase } from '@/lib/supabase-server'
import type { Task, TaskSubmission, Child } from '@/lib/types'

function splitJars(amount: number) {
  const toSave = Math.round(amount * 0.4)
  const toShare = Math.round(amount * 0.2)
  return { toSave, toShare, toSpend: amount - toSave - toShare }
}
function applyXp(child: Child, gain: number) {
  let xp = child.xp + gain
  let level = child.level
  let xpToNext = child.xp_to_next_level
  while (xp >= xpToNext) {
    xp -= xpToNext
    level += 1
    xpToNext = Math.round(xpToNext * 1.2)
  }
  return { xp, level, xp_to_next_level: xpToNext }
}

/**
 * Child submits proof for a task. Reuses an existing pending/rejected submission
 * or creates one, sets it to 'submitted'. If the template is past its
 * auto-approve threshold, immediately approves and awards coins (mirror mobile).
 */
export async function submitTask(input: {
  taskId: string
  childId: string
  proofUrl: string | null
}) {
  const supabase = await createServerSupabase()

  const { data: task } = await supabase
    .from('tasks')
    .select('*')
    .eq('id', input.taskId)
    .maybeSingle()
  if (!task) return { ok: false, error: 'Không tìm thấy nhiệm vụ' }
  const t = task as Task

  // Find a reusable submission (pending or rejected) for this task+child
  const { data: existing } = await supabase
    .from('task_submissions')
    .select('*')
    .eq('task_id', input.taskId)
    .eq('child_id', input.childId)
    .in('status', ['pending', 'rejected'])
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle()

  let submissionId = (existing as TaskSubmission | null)?.id
  if (!submissionId) {
    const { data: created } = await supabase
      .from('task_submissions')
      .insert({ task_id: input.taskId, child_id: input.childId, status: 'pending' })
      .select('id')
      .single()
    submissionId = created?.id
  }
  if (!submissionId) return { ok: false, error: 'Không tạo được bài nộp' }

  const canAuto =
    t.auto_approve_after != null && t.approval_count >= t.auto_approve_after

  if (canAuto) {
    // Auto-approve: award coins immediately
    const earned = t.coin_reward
    const { data: childRow } = await supabase
      .from('children')
      .select('*')
      .eq('id', input.childId)
      .maybeSingle()
    const child = childRow as Child
    const { toSave, toShare, toSpend } = splitJars(earned)
    const xp = applyXp(child, 15)

    await supabase
      .from('task_submissions')
      .update({
        status: 'approved',
        submitted_at: new Date().toISOString(),
        reviewed_at: new Date().toISOString(),
        proof_image_url: input.proofUrl,
        coin_earned: earned,
        auto_approved: true,
      })
      .eq('id', submissionId)
    await supabase.rpc('increment_task_approval_count', { p_task_id: t.id })
    await supabase
      .from('children')
      .update({
        total_coins: child.total_coins + earned,
        save_jar: child.save_jar + toSave,
        share_jar: child.share_jar + toShare,
        spend_jar: child.spend_jar + toSpend,
        ...xp,
        updated_at: new Date().toISOString(),
      })
      .eq('id', child.id)
  } else {
    await supabase
      .from('task_submissions')
      .update({
        status: 'submitted',
        submitted_at: new Date().toISOString(),
        proof_image_url: input.proofUrl,
        parent_note: null,
      })
      .eq('id', submissionId)
  }

  revalidatePath('/child')
  return { ok: true, autoApproved: canAuto }
}

/** Add a dream/wishlist item for the child. */
export async function addDream(input: {
  childId: string
  name: string
  price: number
  icon?: string
}) {
  const supabase = await createServerSupabase()
  const { error } = await supabase.from('dream_items').insert({
    child_id: input.childId,
    name: input.name,
    price: input.price,
    icon: input.icon ?? '🎁',
  })
  if (error) return { ok: false, error: error.message }
  revalidatePath('/child/dreams')
  return { ok: true }
}

/**
 * Redeem a fully-funded dream: deduct price across jars (save 40%, share 20%,
 * rest spend — mirror mobile), mark purchased.
 */
export async function redeemDream(input: { childId: string; dreamId: string; price: number }) {
  const supabase = await createServerSupabase()
  const { data: childRow } = await supabase
    .from('children')
    .select('*')
    .eq('id', input.childId)
    .maybeSingle()
  if (!childRow) return { ok: false, error: 'Không tìm thấy hồ sơ con' }
  const child = childRow as Child
  if (child.total_coins < input.price) return { ok: false, error: 'Chưa đủ xu' }

  const fromSave = Math.min(Math.round(input.price * 0.4), child.save_jar)
  const fromShare = Math.min(Math.round(input.price * 0.2), child.share_jar)
  const fromSpend = Math.min(input.price - fromSave - fromShare, child.spend_jar)

  await supabase
    .from('children')
    .update({
      total_coins: Math.max(0, child.total_coins - input.price),
      save_jar: child.save_jar - fromSave,
      share_jar: child.share_jar - fromShare,
      spend_jar: child.spend_jar - fromSpend,
      updated_at: new Date().toISOString(),
    })
    .eq('id', child.id)

  await supabase.from('dream_items').update({ is_purchased: true }).eq('id', input.dreamId)
  revalidatePath('/child/dreams')
  return { ok: true }
}

/** Delete a dream item. */
export async function deleteDream(input: { dreamId: string }) {
  const supabase = await createServerSupabase()
  await supabase.from('dream_items').delete().eq('id', input.dreamId)
  revalidatePath('/child/dreams')
  return { ok: true }
}

/** Update an unpurchased dream's name, price, and icon. */
export async function updateDream(input: {
  dreamId: string
  name: string
  price: number
  icon: string
}) {
  const supabase = await createServerSupabase()
  await supabase
    .from('dream_items')
    .update({ name: input.name, price: input.price, icon: input.icon })
    .eq('id', input.dreamId)
    .eq('is_purchased', false)
  revalidatePath('/child/dreams')
  return { ok: true }
}

/** Transfer coins from spend jar to save/share (mirror mobile transferToJar). */
export async function transferJar(input: {
  childId: string
  to: 'save' | 'share'
  amount: number
}) {
  const supabase = await createServerSupabase()
  const { data: childRow } = await supabase
    .from('children')
    .select('*')
    .eq('id', input.childId)
    .maybeSingle()
  if (!childRow) return { ok: false, error: 'Không tìm thấy hồ sơ con' }
  const child = childRow as Child
  if (input.amount <= 0 || child.spend_jar < input.amount) {
    return { ok: false, error: 'Số xu không hợp lệ' }
  }
  const updates: Partial<Child> = { spend_jar: child.spend_jar - input.amount }
  if (input.to === 'save') updates.save_jar = child.save_jar + input.amount
  else updates.share_jar = child.share_jar + input.amount

  await supabase.from('children').update(updates).eq('id', child.id)
  revalidatePath('/child/jars')
  return { ok: true }
}
