'use server'

import { revalidatePath } from 'next/cache'
import { createServerSupabase } from '@/lib/supabase-server'
import { getActivePlan } from '@/lib/app/subscription'
import type { Child, Task, TaskSubmission } from '@/lib/types'

/**
 * Add a child to the parent's family, enforcing the plan's max_children limit.
 * Creates the family on first use if missing (mirrors the signup trigger,
 * idempotent).
 */
export async function addChildAction(input: {
  name: string
  age: number
  avatarEmoji: string
}) {
  const supabase = await createServerSupabase()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { ok: false, error: 'unauthorized' }

  if (!input.name.trim()) return { ok: false, error: 'Vui lòng nhập tên con' }

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

  const { error } = await supabase.from('children').insert({
    family_id: family.id,
    name: input.name.trim(),
    age: input.age,
    avatar_emoji: input.avatarEmoji,
  })
  if (error) return { ok: false, error: error.message }

  revalidatePath('/parent/settings')
  revalidatePath('/role')
  return { ok: true }
}

/** Edit a child's name / age / avatar (only within the parent's own family). */
export async function updateChildAction(input: {
  childId: string
  name: string
  age: number
  avatarEmoji: string
}) {
  const supabase = await createServerSupabase()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { ok: false, error: 'unauthorized' }
  if (!input.name.trim()) return { ok: false, error: 'Vui lòng nhập tên con' }

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

  const { error } = await supabase
    .from('children')
    .update({
      name: input.name.trim(),
      age: input.age,
      avatar_emoji: input.avatarEmoji,
      updated_at: new Date().toISOString(),
    })
    .eq('id', input.childId)
  if (error) return { ok: false, error: error.message }

  revalidatePath('/parent/settings')
  revalidatePath('/role')
  return { ok: true }
}

function qualityMultiplier(rating: number): number {
  if (rating === 1) return 0.8
  if (rating === 3) return 1.2
  return 1.0
}

/** Split an amount into the 3 jars (mirror mobile _addCoins): save 40%, share 20%, spend rest. */
function splitJars(amount: number) {
  const toSave = Math.round(amount * 0.4)
  const toShare = Math.round(amount * 0.2)
  const toSpend = amount - toSave - toShare
  return { toSave, toShare, toSpend }
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
  const { toSave, toShare, toSpend } = splitJars(earned)
  const xp = applyXp(row.child, 15)

  await supabase
    .from('task_submissions')
    .update({
      status: 'approved',
      reviewed_at: new Date().toISOString(),
      quality_rating: rating,
      coin_earned: earned,
    })
    .eq('id', submissionId)

  await supabase.rpc('increment_task_approval_count', { p_task_id: row.task.id })

  await supabase
    .from('children')
    .update({
      total_coins: row.child.total_coins + earned,
      save_jar: row.child.save_jar + toSave,
      share_jar: row.child.share_jar + toShare,
      spend_jar: row.child.spend_jar + toSpend,
      ...xp,
      updated_at: new Date().toISOString(),
    })
    .eq('id', row.child.id)

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
  return { ok: true }
}
