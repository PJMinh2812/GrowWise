'use server'

import { revalidatePath } from 'next/cache'
import { createServerSupabase } from '@/lib/supabase-server'
import { bandFor, type RoadmapTask } from '@/lib/app/roadmap-bands'

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

  const tasks = bandFor((child.age as number) ?? 8)
  const rows = tasks.map((t) => ({
    family_id: family.id,
    child_id: childId,
    created_by: user.id,
    title: t.title,
    description: t.description,
    category: t.category,
    icon: t.icon,
    coin_reward: t.coin_reward,
    is_template: true,
    is_active: true,
    approval_count: 0,
    has_penalty: true,
    penalty_percent: 10,
    auto_approve_after: 0, // tự duyệt → lộ trình tự chạy (nạp xu cuối ngày)
  }))
  const { error } = await supabase.from('tasks').insert(rows)
  if (error) return { ok: false, error: error.message }

  revalidatePath('/child')
  revalidatePath('/child/tasks')
  revalidatePath('/parent')
  return { ok: true, seeded: rows.length }
}

/**
 * Save a parent-curated roadmap (from the AI wizard preview). Inserts the given
 * tasks as active templates for the child. Each task auto-approves by default so
 * coins are credited at the day-end rollover; parents can edit them afterwards.
 */
export async function saveRoadmapTasks(childId: string, tasks: RoadmapTask[]) {
  if (!childId) return { ok: false, error: 'missing childId' }
  if (!tasks?.length) return { ok: false, error: 'Lộ trình trống' }
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
    .select('id')
    .eq('id', childId)
    .eq('family_id', family.id)
    .maybeSingle()
  if (!child) return { ok: false, error: 'unauthorized' }

  const rows = tasks.map((t) => ({
    family_id: family.id,
    child_id: childId,
    created_by: user.id,
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
  }))
  const { error } = await supabase.from('tasks').insert(rows)
  if (error) return { ok: false, error: error.message }

  revalidatePath('/child')
  revalidatePath('/child/tasks')
  revalidatePath('/parent')
  revalidatePath('/parent/roadmap')
  return { ok: true, saved: rows.length }
}
