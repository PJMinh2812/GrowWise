import { createServerSupabase } from '@/lib/supabase-server'
import { startOfTodayVN } from '@/lib/app/day'
import type { Task, TaskSubmission, Child } from '@/lib/types'

export interface SubmissionWithRelations extends TaskSubmission {
  task: Task | null
  child: Child | null
}

/** Submitted (pending review) submissions for a family — the approval queue. */
export async function getPendingSubmissions(
  familyId: string,
): Promise<SubmissionWithRelations[]> {
  const supabase = await createServerSupabase()
  const { data } = await supabase
    .from('task_submissions')
    .select('*, task:tasks!inner(*), child:children(*)')
    .eq('status', 'submitted')
    .eq('task.family_id', familyId)
    .order('created_at', { ascending: true })
  return (data as SubmissionWithRelations[]) ?? []
}

/** Auto-approved submissions within the last 24h (retroactive-reject window). */
export async function getRecentAutoApproved(
  familyId: string,
): Promise<SubmissionWithRelations[]> {
  const supabase = await createServerSupabase()
  const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()
  const { data } = await supabase
    .from('task_submissions')
    .select('*, task:tasks!inner(*), child:children(*)')
    .eq('status', 'approved')
    .eq('auto_approved', true)
    .eq('task.family_id', familyId)
    .gte('reviewed_at', since)
    .order('reviewed_at', { ascending: false })
  return (data as SubmissionWithRelations[]) ?? []
}

/** All submissions for a child (any status), newest first. */
export async function getChildSubmissions(childId: string): Promise<TaskSubmission[]> {
  const supabase = await createServerSupabase()
  const { data } = await supabase
    .from('task_submissions')
    .select('*')
    .eq('child_id', childId)
    .order('created_at', { ascending: false })
  return (data as TaskSubmission[]) ?? []
}

/** A child's submissions created today (VN time), newest first — daily cycle. */
export async function getTodaySubmissions(childId: string): Promise<TaskSubmission[]> {
  const supabase = await createServerSupabase()
  const { data } = await supabase
    .from('task_submissions')
    .select('*')
    .eq('child_id', childId)
    .gte('created_at', startOfTodayVN().toISOString())
    .order('created_at', { ascending: false })
  return (data as TaskSubmission[]) ?? []
}

export async function getSubmission(
  submissionId: string,
): Promise<SubmissionWithRelations | null> {
  const supabase = await createServerSupabase()
  const { data } = await supabase
    .from('task_submissions')
    .select('*, task:tasks(*), child:children(*)')
    .eq('id', submissionId)
    .maybeSingle()
  return (data as SubmissionWithRelations) ?? null
}

/** Weekly coins awarded across a family (sum of coin_earned in last 7 days). */
export async function getWeeklyCoins(familyId: string): Promise<number> {
  const supabase = await createServerSupabase()
  const since = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString()
  const { data } = await supabase
    .from('task_submissions')
    .select('coin_earned, task:tasks!inner(family_id)')
    .eq('status', 'approved')
    .eq('task.family_id', familyId)
    .gte('reviewed_at', since)
  return (data ?? []).reduce(
    (sum: number, r: { coin_earned: number | null }) => sum + (r.coin_earned ?? 0),
    0,
  )
}
