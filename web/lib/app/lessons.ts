import { createServerSupabase } from '@/lib/supabase-server'
import { createAdminClient } from '@/lib/supabase-admin'
import type { Lesson } from '@/lib/types'

/** IDs of lessons a child has completed (for the learning-path progress). */
export async function getCompletedLessonIds(childId: string): Promise<string[]> {
  if (!childId) return []
  const admin = createAdminClient()
  const { data } = await admin
    .from('lesson_completions')
    .select('lesson_id')
    .eq('child_id', childId)
  return (data ?? []).map((r) => r.lesson_id as string)
}

/** Published lessons (optionally filtered by audience) with nested quizzes + options. */
export async function getLessons(audience?: 'child' | 'parent'): Promise<Lesson[]> {
  const supabase = await createServerSupabase()
  let q = supabase
    .from('lessons')
    .select('*, lesson_quizzes(*, quiz_options(*))')
    .eq('is_published', true)
  if (audience) q = q.eq('audience', audience)
  const { data } = await q.order('order_index')
  return (data as Lesson[]) ?? []
}

export async function getLesson(id: string): Promise<Lesson | null> {
  const supabase = await createServerSupabase()
  const { data } = await supabase
    .from('lessons')
    .select('*, lesson_quizzes(*, quiz_options(*))')
    .eq('id', id)
    .maybeSingle()
  return (data as Lesson) ?? null
}
