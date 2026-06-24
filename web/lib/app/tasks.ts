import { createServerSupabase } from '@/lib/supabase-server'
import type { Task } from '@/lib/types'

/** Active task templates for a family (optionally a single child). */
export async function getTaskTemplates(
  familyId: string,
  childId?: string,
  includeInactive = false,
): Promise<Task[]> {
  const supabase = await createServerSupabase()
  let q = supabase
    .from('tasks')
    .select('*')
    .eq('family_id', familyId)
    .eq('is_template', true)
  if (!includeInactive) q = q.eq('is_active', true)
  if (childId) q = q.eq('child_id', childId)
  const { data } = await q.order('created_at', { ascending: false })
  return (data as Task[]) ?? []
}

export async function getTask(taskId: string): Promise<Task | null> {
  const supabase = await createServerSupabase()
  const { data } = await supabase.from('tasks').select('*').eq('id', taskId).maybeSingle()
  return (data as Task) ?? null
}
