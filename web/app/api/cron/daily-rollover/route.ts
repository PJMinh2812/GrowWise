import { NextRequest, NextResponse } from 'next/server'
import { createAdminClient } from '@/lib/supabase-admin'
import { splitAndCreditJars, deductPenalty, lateAdjusted } from '@/lib/app/credit'
import { startOfTodayVN } from '@/lib/app/day'
import type { Task, Child, TaskSubmission } from '@/lib/types'

export const runtime = 'nodejs'

function isAutoApprove(task: Task): boolean {
  return task.auto_approve_after != null && task.approval_count >= task.auto_approve_after
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
 * End-of-day rollover (runs at 00:00 VN). For the day that just ended:
 *  - Auto-approve tasks still 'submitted' (parent didn't act) → approve, grant
 *    XP, and auto-credit coins split across the 3 jars.
 *  - Active tasks with a penalty that got NO submission that day → record a
 *    'missed' submission and deduct penalty_percent% of the reward.
 * Manual tasks left 'submitted' are untouched (the child did submit).
 */
export async function GET(request: NextRequest) {
  const authHeader = request.headers.get('authorization')
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const admin = createAdminClient()
  const now = new Date().toISOString()
  const todayStart = startOfTodayVN()
  const dayStart = new Date(todayStart.getTime() - 24 * 3600 * 1000)
  // Stamp 'missed' rows just before midnight so they belong to the ending day,
  // not the new day (which would wrongly mark today's task as already missed).
  const missedStamp = new Date(todayStart.getTime() - 1000).toISOString()

  let approved = 0
  let missed = 0

  // 1) Auto-approve lingering submitted auto-tasks.
  const { data: subs } = await admin
    .from('task_submissions')
    .select('*, task:tasks!inner(*), child:children(*)')
    .eq('status', 'submitted')
  for (const s of (subs ?? []) as (TaskSubmission & { task: Task; child: Child })[]) {
    if (!s.task || !s.child || !isAutoApprove(s.task)) continue
    // Reload the child fresh so multiple credits in one run don't clobber.
    const { data: childRow } = await admin.from('children').select('*').eq('id', s.child.id).maybeSingle()
    if (!childRow) continue
    const child = childRow as Child
    const { earned, wasLate } = lateAdjusted(s.task.coin_reward, s.task, s.submitted_at)
    const xp = applyXp(child, 15)
    await admin
      .from('task_submissions')
      .update({ status: 'approved', reviewed_at: now, coin_earned: earned, auto_approved: true, collected: true, was_late: wasLate })
      .eq('id', s.id)
    await admin.rpc('increment_task_approval_count', { p_task_id: s.task.id })
    await admin.from('children').update({ ...xp, updated_at: now }).eq('id', child.id)
    await splitAndCreditJars(admin, child, earned, s.task.title)
    approved += 1
  }

  // 2) Penalty for active penalty-tasks with no submission during the ending day.
  const { data: tasks } = await admin
    .from('tasks')
    .select('*')
    .eq('is_template', true)
    .eq('is_active', true)
    .eq('has_penalty', true)
  for (const task of (tasks ?? []) as Task[]) {
    const { count } = await admin
      .from('task_submissions')
      .select('id', { count: 'exact', head: true })
      .eq('task_id', task.id)
      .eq('child_id', task.child_id)
      .gte('created_at', dayStart.toISOString())
      .lt('created_at', todayStart.toISOString())
    if ((count ?? 0) > 0) continue

    const { data: childRow } = await admin.from('children').select('*').eq('id', task.child_id).maybeSingle()
    if (!childRow) continue
    const child = childRow as Child
    const penalty = Math.round(task.coin_reward * (task.penalty_percent / 100))
    if (penalty <= 0) continue

    await admin
      .from('task_submissions')
      .insert({ task_id: task.id, child_id: task.child_id, status: 'missed', created_at: missedStamp })
    await deductPenalty(admin, child, penalty, `Bỏ lỡ: ${task.title}`)
    missed += 1
  }

  return NextResponse.json({ approved, missed })
}
