import { createServerSupabase } from '@/lib/supabase-server'
import { getCurrentUser } from '@/lib/app/auth'

export interface ActiveSurvey {
  id: string
  title: string
  description: string | null
  url: string
}

/**
 * The newest published survey for an audience that the current subject
 * (parent = user; child = user+child) hasn't dismissed yet. null if none.
 */
export async function getActiveSurveyFor(
  audience: 'parent' | 'child',
  childId?: string | null,
): Promise<ActiveSurvey | null> {
  const user = await getCurrentUser()
  if (!user) return null

  const supabase = await createServerSupabase()
  const { data: surveys } = await supabase
    .from('surveys')
    .select('id, title, description, url')
    .eq('is_published', true)
    .in('audience', [audience, 'all'])
    .order('published_at', { ascending: false })
  if (!surveys || surveys.length === 0) return null

  let q = supabase.from('survey_dismissals').select('survey_id').eq('user_id', user.id)
  q = childId ? q.eq('child_id', childId) : q.is('child_id', null)
  const { data: dismissed } = await q
  const done = new Set((dismissed ?? []).map(d => d.survey_id as string))

  return (surveys.find(s => !done.has(s.id)) as ActiveSurvey | undefined) ?? null
}
