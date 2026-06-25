'use server'

import { revalidatePath } from 'next/cache'
import { createServerSupabase } from '@/lib/supabase-server'
import { bandFor, withSchedule, type RoadmapTask } from '@/lib/app/roadmap-bands'
import type { RoadmapStage } from '@/lib/types'

function taskRow(
  familyId: string,
  childId: string,
  userId: string,
  t: RoadmapTask,
  stage: number,
) {
  return {
    family_id: familyId,
    child_id: childId,
    created_by: userId,
    title: t.title,
    description: t.description ?? '',
    category: t.category ?? 'Học tập',
    icon: t.icon ?? '⭐',
    coin_reward: Math.max(0, Math.round(t.coin_reward ?? 20)),
    is_template: true,
    is_active: true,
    approval_count: 0,
    has_penalty: t.has_penalty ?? true,
    penalty_percent: t.penalty_percent ?? 10,
    auto_approve_after: (t.auto_approve ?? true) ? 0 : null,
    scheduled_time: t.scheduled_time ?? null,
    duration_minutes: t.duration_minutes ?? 15,
    frequency: t.frequency ?? 'daily',
    stage: t.stage ?? stage,
  }
}

/**
 * Seed the age-appropriate roadmap tasks for a child. Idempotent: does nothing
 * if the child already has active task templates (so it won't duplicate).
 * Tasks auto-approve so the routine runs without parent effort; coins are
 * credited at the day-end rollover and missed tasks incur a penalty.
 */
export async function seedRoadmapForChild(childId: string) {
  if (!childId) return { ok: false, error: 'missing childId' }
  const supabase = await createServerSupabase()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return { ok: false, error: 'unauthorized' }

  const { data: family } = await supabase
    .from('families')
    .select('id')
    .eq('parent_id', user.id)
    .maybeSingle()
  if (!family) return { ok: false, error: 'no family' }

  const { data: child } = await supabase
    .from('children')
    .select('id, age')
    .eq('id', childId)
    .eq('family_id', family.id)
    .maybeSingle()
  if (!child) return { ok: false, error: 'unauthorized' }

  // Idempotent: skip if the child already has active templates.
  const { count } = await supabase
    .from('tasks')
    .select('id', { count: 'exact', head: true })
    .eq('child_id', childId)
    .eq('is_template', true)
    .eq('is_active', true)
  if ((count ?? 0) > 0) return { ok: true, seeded: 0 }

  const tasks = withSchedule(bandFor((child.age as number) ?? 8))
  const rows = tasks.map((t) => taskRow(family.id, childId, user.id, t, 1))
  const { error } = await supabase.from('tasks').insert(rows)
  if (error) return { ok: false, error: error.message }

  revalidatePath('/child')
  revalidatePath('/child/tasks')
  revalidatePath('/parent')
  return { ok: true, seeded: rows.length }
}

/** Resolve the parent's family + verify the child belongs to it. */
async function ownChild(childId: string) {
  const supabase = await createServerSupabase()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return { supabase, user: null, familyId: null }
  const { data: family } = await supabase
    .from('families')
    .select('id')
    .eq('parent_id', user.id)
    .maybeSingle()
  if (!family) return { supabase, user, familyId: null }
  const { data: child } = await supabase
    .from('children')
    .select('id')
    .eq('id', childId)
    .eq('family_id', family.id)
    .maybeSingle()
  return { supabase, user, familyId: child ? (family.id as string) : null }
}

/**
 * Save a parent-curated roadmap (from the AI wizard preview). Inserts the given
 * tasks (with schedule) as active templates, and stores the 12-stage year plan.
 * `stage` lets "suggest more" add to the current stage.
 */
export async function saveRoadmapTasks(
  childId: string,
  tasks: RoadmapTask[],
  stages?: RoadmapStage[],
  stage = 1,
) {
  if (!childId) return { ok: false, error: 'missing childId' }
  if (!tasks?.length) return { ok: false, error: 'Lộ trình trống' }
  const { supabase, user, familyId } = await ownChild(childId)
  if (!user) return { ok: false, error: 'unauthorized' }
  if (!familyId) return { ok: false, error: 'unauthorized' }

  const rows = tasks.map((t) => taskRow(familyId, childId, user.id, t, stage))
  const { error } = await supabase.from('tasks').insert(rows)
  if (error) return { ok: false, error: error.message }

  if (stages?.length) {
    await supabase
      .from('roadmap_plans')
      .upsert(
        { child_id: childId, current_stage: 1, stages, updated_at: new Date().toISOString() },
        { onConflict: 'child_id' },
      )
  }

  revalidatePath('/child')
  revalidatePath('/child/tasks')
  revalidatePath('/parent')
  revalidatePath('/parent/roadmap')
  return { ok: true, saved: rows.length }
}

/** Read a child's year plan (12 stages + current stage). */
export async function getRoadmapPlan(childId: string) {
  const supabase = await createServerSupabase()
  const { data } = await supabase
    .from('roadmap_plans')
    .select('*')
    .eq('child_id', childId)
    .maybeSingle()
  return data as { child_id: string; current_stage: number; stages: RoadmapStage[] } | null
}

/** Move to the next monthly stage (parent action). Caps at 12. */
export async function advanceStage(childId: string) {
  const { supabase, familyId } = await ownChild(childId)
  if (!familyId) return { ok: false, error: 'unauthorized' }
  const { data: plan } = await supabase
    .from('roadmap_plans')
    .select('current_stage, stages')
    .eq('child_id', childId)
    .maybeSingle()
  if (!plan) return { ok: false, error: 'Chưa có lộ trình' }
  const total = Array.isArray(plan.stages) ? plan.stages.length : 12
  const next = Math.min((plan.current_stage as number) + 1, total)
  await supabase
    .from('roadmap_plans')
    .update({ current_stage: next, updated_at: new Date().toISOString() })
    .eq('child_id', childId)
  revalidatePath('/parent/roadmap')
  return { ok: true, current_stage: next }
}
