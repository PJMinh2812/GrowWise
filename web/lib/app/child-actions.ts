'use server'

import { revalidatePath } from 'next/cache'
import { createServerSupabase } from '@/lib/supabase-server'
import { createAdminClient } from '@/lib/supabase-admin'
import type { Task, TaskSubmission, Child } from '@/lib/types'

/**
 * Mark a lesson completed for a child (idempotent). Uses the service-role client
 * so it works regardless of RLS. Called when a child finishes a video/story.
 */
export async function completeLesson(childId: string, lessonId: string) {
  if (!childId || !lessonId) return { ok: false }
  const admin = createAdminClient()
  const { error } = await admin
    .from('lesson_completions')
    .upsert({ child_id: childId, lesson_id: lessonId }, { onConflict: 'child_id,lesson_id' })
  if (error) {
    console.error('[completeLesson]', error)
    return { ok: false, error: error.message }
  }
  revalidatePath('/child/learn')
  return { ok: true }
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

  let coinsEarned = 0
  let leveledUp = false

  if (canAuto) {
    // Auto-approve: award coins immediately
    const earned = t.coin_reward
    coinsEarned = earned
    const { data: childRow } = await supabase
      .from('children')
      .select('*')
      .eq('id', input.childId)
      .maybeSingle()
    const child = childRow as Child
    const xp = applyXp(child, 15)
    leveledUp = xp.level > child.level

    // Coins are NOT added to jars here — the child "collects" them into a jar of
    // their choice afterwards (collected=false). Only XP is granted now.
    await supabase
      .from('task_submissions')
      .update({
        status: 'approved',
        submitted_at: new Date().toISOString(),
        reviewed_at: new Date().toISOString(),
        proof_image_url: input.proofUrl,
        coin_earned: earned,
        auto_approved: true,
        collected: false,
      })
      .eq('id', submissionId)
    await supabase.rpc('increment_task_approval_count', { p_task_id: t.id })
    await supabase
      .from('children')
      .update({ ...xp, updated_at: new Date().toISOString() })
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
  revalidatePath('/child/tasks')
  return { ok: true, autoApproved: canAuto, coinsEarned, leveledUp }
}

/**
 * Child "collects" the coins of an approved task into a chosen jar.
 * Adds coin_earned to the jar + total_coins, marks the submission collected,
 * and records an income row in child_transactions. Idempotent.
 */
export async function collectReward(
  submissionId: string,
  jar: 'spend' | 'save' | 'share',
) {
  const supabase = await createServerSupabase()
  const { data: sub } = await supabase
    .from('task_submissions')
    .select('id, child_id, coin_earned, status, collected, task_id')
    .eq('id', submissionId)
    .maybeSingle()
  if (!sub) return { ok: false, error: 'Không tìm thấy bài nộp' }
  if (sub.status !== 'approved') return { ok: false, error: 'Nhiệm vụ chưa được duyệt' }
  if (sub.collected) return { ok: true, amount: 0 } // already collected
  const amount = (sub.coin_earned as number) ?? 0

  const { data: childRow } = await supabase
    .from('children')
    .select('*')
    .eq('id', sub.child_id)
    .maybeSingle()
  if (!childRow) return { ok: false, error: 'Không tìm thấy hồ sơ con' }
  const child = childRow as Child
  const jarCol = jar === 'save' ? 'save_jar' : jar === 'share' ? 'share_jar' : 'spend_jar'

  await supabase
    .from('children')
    .update({
      total_coins: child.total_coins + amount,
      [jarCol]: (child[jarCol as 'spend_jar' | 'save_jar' | 'share_jar'] as number) + amount,
      updated_at: new Date().toISOString(),
    })
    .eq('id', child.id)

  await supabase.from('task_submissions').update({ collected: true }).eq('id', submissionId)

  // best-effort ledger entry
  let title = 'Nhiệm vụ'
  const { data: task } = await supabase.from('tasks').select('title').eq('id', sub.task_id).maybeSingle()
  if (task?.title) title = task.title as string
  await supabase.from('child_transactions').insert({
    child_id: child.id,
    type: 'income',
    amount,
    note: title,
    jar,
  })

  revalidatePath('/child')
  revalidatePath('/child/tasks')
  revalidatePath('/child/jars')
  revalidatePath('/child/thu-chi')
  return { ok: true, amount }
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

  const { data: dream } = await supabase
    .from('dream_items')
    .select('name')
    .eq('id', input.dreamId)
    .maybeSingle()
  await supabase.from('child_transactions').insert({
    child_id: child.id,
    type: 'expense',
    amount: input.price,
    note: dream?.name ? `Đổi quà: ${dream.name}` : 'Đổi quà',
  })

  revalidatePath('/child/dreams')
  revalidatePath('/child/thu-chi')
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
