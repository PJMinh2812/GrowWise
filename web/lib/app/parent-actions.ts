'use server'

import { revalidatePath } from 'next/cache'
import { cookies } from 'next/headers'
import { createServerSupabase } from '@/lib/supabase-server'
import { getActivePlan } from '@/lib/app/subscription'
import { splitJars, splitAndCreditJars } from '@/lib/app/credit'
import type { Child, Task, TaskSubmission } from '@/lib/types'
import { calcAge } from '@/lib/types'

/** A task auto-approves once its approval_count reaches the threshold. */
function isAutoApprove(task: Task): boolean {
  return task.auto_approve_after != null && task.approval_count >= task.auto_approve_after
}

/**
 * Add a child to the parent's family, enforcing the plan's max_children limit.
 * Creates the family on first use if missing (mirrors the signup trigger,
 * idempotent).
 */
export async function addChildAction(input: {
  name: string
  dateOfBirth: string
  avatarEmoji: string
}) {
  const supabase = await createServerSupabase()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { ok: false, error: 'unauthorized' }

  if (!input.name.trim()) return { ok: false, error: 'Vui lòng nhập tên con' }
  if (!input.dateOfBirth) return { ok: false, error: 'Vui lòng chọn ngày sinh' }

  // Ensure family exists
  let { data: family } = await supabase
    .from('families')
    .select('id')
    .eq('parent_id', user.id)
    .maybeSingle()
  if (!family) {
    const { data: created, error: famErr } = await supabase
      .from('families')
      .insert({ parent_id: user.id })
      .select('id')
      .single()
    if (famErr || !created) {
      return { ok: false, error: famErr?.message ?? 'Không tạo được hồ sơ gia đình' }
    }
    family = created
  }

  // Enforce max children
  const [{ count }, plan] = await Promise.all([
    supabase
      .from('children')
      .select('id', { count: 'exact', head: true })
      .eq('family_id', family.id),
    getActivePlan(),
  ])
  if ((count ?? 0) >= plan.maxChildren) {
    return {
      ok: false,
      limit: true,
      error: `Gói hiện tại chỉ cho phép ${plan.maxChildren} hồ sơ con. Nâng cấp gói Gia Đình để thêm.`,
    }
  }

  const age = calcAge(input.dateOfBirth)
  const { error } = await supabase.from('children').insert({
    family_id: family.id,
    name: input.name.trim(),
    age,
    date_of_birth: input.dateOfBirth,
    avatar_emoji: input.avatarEmoji,
  })
  if (error) return { ok: false, error: error.message }

  revalidatePath('/parent/settings')
  revalidatePath('/role')
  return { ok: true }
}

/** Edit a child's name / DOB / avatar (only within the parent's own family). */
export async function updateChildAction(input: {
  childId: string
  name: string
  dateOfBirth: string
  avatarEmoji: string
}) {
  const supabase = await createServerSupabase()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { ok: false, error: 'unauthorized' }
  if (!input.name.trim()) return { ok: false, error: 'Vui lòng nhập tên con' }
  if (!input.dateOfBirth) return { ok: false, error: 'Vui lòng chọn ngày sinh' }

  const { data: family } = await supabase
    .from('families')
    .select('id')
    .eq('parent_id', user.id)
    .maybeSingle()
  if (!family) return { ok: false, error: 'Chưa có hồ sơ gia đình' }

  // Ensure the child belongs to this parent's family
  const { data: child } = await supabase
    .from('children')
    .select('id')
    .eq('id', input.childId)
    .eq('family_id', family.id)
    .maybeSingle()
  if (!child) return { ok: false, error: 'unauthorized' }

  const age = calcAge(input.dateOfBirth)
  const { error } = await supabase
    .from('children')
    .update({
      name: input.name.trim(),
      age,
      date_of_birth: input.dateOfBirth,
      avatar_emoji: input.avatarEmoji,
      updated_at: new Date().toISOString(),
    })
    .eq('id', input.childId)
  if (error) return { ok: false, error: error.message }

  revalidatePath('/parent/settings')
  revalidatePath('/role')
  return { ok: true }
}

/**
 * Parent deducts coins from a child for an unplanned expense (chi phát sinh).
 * Subtracts from jars Tiêu → Tiết kiệm → Sẻ chia, lowers total_coins, and logs
 * an expense in child_transactions.
 */
export async function deductCoins(input: { childId: string; amount: number; note: string }) {
  const supabase = await createServerSupabase()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return { ok: false, error: 'unauthorized' }
  const amount = Math.round(input.amount)
  if (!amount || amount <= 0) return { ok: false, error: 'Số xu không hợp lệ' }

  const { data: family } = await supabase
    .from('families')
    .select('id')
    .eq('parent_id', user.id)
    .maybeSingle()
  if (!family) return { ok: false, error: 'Chưa có hồ sơ gia đình' }

  const { data: childRow } = await supabase
    .from('children')
    .select('*')
    .eq('id', input.childId)
    .eq('family_id', family.id)
    .maybeSingle()
  if (!childRow) return { ok: false, error: 'unauthorized' }
  const child = childRow as Child
  if (child.total_coins < amount) return { ok: false, error: 'Con không đủ xu' }

  const fromSpend = Math.min(amount, child.spend_jar)
  const fromSave = Math.min(amount - fromSpend, child.save_jar)
  const fromShare = Math.min(amount - fromSpend - fromSave, child.share_jar)

  await supabase
    .from('children')
    .update({
      total_coins: Math.max(0, child.total_coins - amount),
      spend_jar: child.spend_jar - fromSpend,
      save_jar: child.save_jar - fromSave,
      share_jar: child.share_jar - fromShare,
      updated_at: new Date().toISOString(),
    })
    .eq('id', child.id)

  await supabase.from('child_transactions').insert({
    child_id: child.id,
    type: 'expense',
    amount,
    note: input.note?.trim() || 'Chi phát sinh',
    created_by: user.id,
  })

  revalidatePath('/parent/settings')
  revalidatePath('/child/thu-chi')
  return { ok: true }
}

/** Update the logged-in parent's display name and avatar URL. */
export async function updateParentProfileAction(input: {
  fullName: string
  avatarUrl: string
}) {
  const supabase = await createServerSupabase()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return { ok: false, error: 'unauthorized' }

  const { error } = await supabase
    .from('profiles')
    .update({ full_name: input.fullName.trim(), avatar_url: input.avatarUrl.trim() || null })
    .eq('id', user.id)
  if (error) return { ok: false, error: error.message }

  revalidatePath('/parent/settings')
  revalidatePath('/parent')
  return { ok: true }
}

/** Child self-edits their own name / avatar (no DOB, no age). */
export async function updateChildSelfAction(input: {
  name: string
  avatarEmoji: string
  avatarUrl?: string
}) {
  const supabase = await createServerSupabase()
  const cookieStore = await cookies()
  const childId = cookieStore.get('gw_child_id')?.value
  if (!childId) return { ok: false, error: 'Chưa chọn hồ sơ con' }
  if (!input.name.trim()) return { ok: false, error: 'Vui lòng nhập tên' }

  const { error } = await supabase
    .from('children')
    .update({
      name: input.name.trim(),
      avatar_emoji: input.avatarEmoji,
      avatar_url: input.avatarUrl?.trim() || null,
      updated_at: new Date().toISOString(),
    })
    .eq('id', childId)
  if (error) return { ok: false, error: error.message }

  revalidatePath('/child')
  revalidatePath('/child/settings')
  return { ok: true }
}

function qualityMultiplier(rating: number): number {
  if (rating === 1) return 0.8
  if (rating === 3) return 1.2
  return 1.0
}

/** Apply XP gain with level-ups (mirror mobile _addXp). */
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

async function loadSubmission(submissionId: string) {
  const supabase = await createServerSupabase()
  const { data } = await supabase
    .from('task_submissions')
    .select('*, task:tasks(*), child:children(*)')
    .eq('id', submissionId)
    .maybeSingle()
  return { supabase, row: data as (TaskSubmission & { task: Task; child: Child }) | null }
}

/** Approve a submission: award coins to jars, +15 XP, bump approval_count, add memory. */
export async function approveSubmission(submissionId: string, rating: number) {
  const { supabase, row } = await loadSubmission(submissionId)
  if (!row || !row.task || !row.child) return { ok: false, error: 'Không tìm thấy bài nộp' }

  const earned = Math.round(row.task.coin_reward * qualityMultiplier(rating))
  const xp = applyXp(row.child, 15)

  // Auto-approve tasks: the machine credits + auto-splits the coins (no child
  // "collect" step). Manual tasks: coins wait for the child to choose a jar
  // (collected=false).
  const auto = isAutoApprove(row.task)

  await supabase
    .from('task_submissions')
    .update({
      status: 'approved',
      reviewed_at: new Date().toISOString(),
      quality_rating: rating,
      coin_earned: earned,
      auto_approved: auto,
      collected: auto,
    })
    .eq('id', submissionId)

  await supabase.rpc('increment_task_approval_count', { p_task_id: row.task.id })

  await supabase
    .from('children')
    .update({ ...xp, updated_at: new Date().toISOString() })
    .eq('id', row.child.id)

  if (auto) await splitAndCreditJars(supabase, row.child, earned, row.task.title)

  await supabase.from('memories').insert({
    family_id: row.task.family_id,
    child_id: row.child.id,
    task_title: row.task.title,
    emoji: row.task.icon,
    note: 'Hoàn thành xuất sắc!',
    ...(row.proof_image_url ? { proof_image_url: row.proof_image_url } : {}),
  })

  revalidatePath('/parent')
  return { ok: true, earned }
}

/** Reject a submission with an optional reason (stored in parent_note). */
export async function rejectSubmission(submissionId: string, reason?: string) {
  const supabase = await createServerSupabase()
  await supabase
    .from('task_submissions')
    .update({
      status: 'rejected',
      reviewed_at: new Date().toISOString(),
      ...(reason ? { parent_note: reason } : {}),
    })
    .eq('id', submissionId)
  revalidatePath('/parent')
  return { ok: true }
}

/** Retroactively reject an auto-approved submission within 24h: claw back coins, decrement count. */
export async function retroactiveReject(submissionId: string) {
  const { supabase, row } = await loadSubmission(submissionId)
  if (!row || !row.task || !row.child) return { ok: false, error: 'Không tìm thấy bài nộp' }

  const earned = row.coin_earned ?? 0
  const { toSave, toShare, toSpend } = splitJars(earned)

  await supabase
    .from('task_submissions')
    .update({
      status: 'pending',
      coin_earned: null,
      reviewed_at: null,
      auto_approved: false,
      proof_image_url: null,
    })
    .eq('id', submissionId)

  await supabase.rpc('decrement_task_approval_count', { p_task_id: row.task.id })

  await supabase
    .from('children')
    .update({
      total_coins: Math.max(0, row.child.total_coins - earned),
      save_jar: Math.max(0, row.child.save_jar - toSave),
      share_jar: Math.max(0, row.child.share_jar - toShare),
      spend_jar: Math.max(0, row.child.spend_jar - toSpend),
      updated_at: new Date().toISOString(),
    })
    .eq('id', row.child.id)

  revalidatePath('/parent')
  return { ok: true }
}

/** Create a reusable task template (parent). */
export async function createTaskAction(input: {
  childId: string
  title: string
  description: string
  category: string
  icon: string
  coinReward: number
  autoApproveAfter?: number | null
  hasPenalty?: boolean
  penaltyPercent?: number
}) {
  const supabase = await createServerSupabase()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { ok: false, error: 'unauthorized' }

  const { data: family } = await supabase
    .from('families')
    .select('id')
    .eq('parent_id', user.id)
    .maybeSingle()
  if (!family) return { ok: false, error: 'Chưa có hồ sơ gia đình' }

  const { error } = await supabase.from('tasks').insert({
    family_id: family.id,
    child_id: input.childId,
    created_by: user.id,
    title: input.title,
    description: input.description,
    category: input.category,
    icon: input.icon,
    coin_reward: input.coinReward,
    is_template: true,
    is_active: true,
    approval_count: 0,
    has_penalty: input.hasPenalty ?? false,
    penalty_percent: input.penaltyPercent ?? 10,
    ...(input.autoApproveAfter != null ? { auto_approve_after: input.autoApproveAfter } : {}),
  })

  if (error) return { ok: false, error: error.message }
  revalidatePath('/parent')
  revalidatePath('/parent/roadmap')
  return { ok: true }
}

/** Verify a task belongs to the logged-in parent's family. Returns familyId or null. */
async function ownTask(taskId: string) {
  const supabase = await createServerSupabase()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return { supabase, ok: false as const }
  const { data: family } = await supabase
    .from('families')
    .select('id')
    .eq('parent_id', user.id)
    .maybeSingle()
  if (!family) return { supabase, ok: false as const }
  const { data: task } = await supabase
    .from('tasks')
    .select('id')
    .eq('id', taskId)
    .eq('family_id', family.id)
    .maybeSingle()
  return { supabase, ok: Boolean(task) }
}

/** Edit an existing task template (parent fine-tunes the roadmap). */
export async function updateTaskAction(input: {
  taskId: string
  title: string
  description: string
  category: string
  icon: string
  coinReward: number
  autoApprove?: boolean
  hasPenalty?: boolean
  penaltyPercent?: number
}) {
  const { supabase, ok } = await ownTask(input.taskId)
  if (!ok) return { ok: false, error: 'unauthorized' }
  const { error } = await supabase
    .from('tasks')
    .update({
      title: input.title,
      description: input.description,
      category: input.category,
      icon: input.icon,
      coin_reward: Math.max(0, Math.round(input.coinReward)),
      ...(input.hasPenalty != null ? { has_penalty: input.hasPenalty } : {}),
      ...(input.penaltyPercent != null ? { penalty_percent: input.penaltyPercent } : {}),
      ...(input.autoApprove != null ? { auto_approve_after: input.autoApprove ? 0 : null } : {}),
    })
    .eq('id', input.taskId)
  if (error) return { ok: false, error: error.message }
  revalidatePath('/parent/roadmap')
  revalidatePath('/child/tasks')
  return { ok: true }
}

/** Pause/resume a task (is_active). */
export async function setTaskActiveAction(taskId: string, active: boolean) {
  const { supabase, ok } = await ownTask(taskId)
  if (!ok) return { ok: false, error: 'unauthorized' }
  const { error } = await supabase.from('tasks').update({ is_active: active }).eq('id', taskId)
  if (error) return { ok: false, error: error.message }
  revalidatePath('/parent/roadmap')
  revalidatePath('/child/tasks')
  return { ok: true }
}

/** Remove a task from the roadmap (deletes its submissions then the task). */
export async function deleteTaskAction(taskId: string) {
  const { supabase, ok } = await ownTask(taskId)
  if (!ok) return { ok: false, error: 'unauthorized' }
  await supabase.from('task_submissions').delete().eq('task_id', taskId)
  const { error } = await supabase.from('tasks').delete().eq('id', taskId)
  if (error) {
    // Fallback: if a FK blocks deletion, just deactivate.
    await supabase.from('tasks').update({ is_active: false }).eq('id', taskId)
  }
  revalidatePath('/parent/roadmap')
  revalidatePath('/child/tasks')
  return { ok: true }
}
