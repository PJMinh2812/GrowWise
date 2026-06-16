import { createServerSupabase } from '@/lib/supabase-server'
import { getCurrentUser } from '@/lib/app/auth'
import { makeToken } from '@/lib/app/survey-token'

export interface ActiveSurvey {
  id: string
  title: string
  description: string | null
  url: string
  /** true when the link carries a verification token (banner hides only after a real submit). */
  verified: boolean
}

interface SurveyRow {
  id: string
  title: string
  description: string | null
  url: string
  min_age: number | null
  max_age: number | null
}

/**
 * The newest published survey for an audience that the current subject
 * (parent = user; child = user+child) hasn't dismissed yet. null if none.
 * For child viewers, surveys outside [min_age, max_age] are skipped.
 */
export async function getActiveSurveyFor(
  audience: 'parent' | 'child',
  child?: { id: string; age: number } | null,
): Promise<ActiveSurvey | null> {
  const user = await getCurrentUser()
  if (!user) return null

  const supabase = await createServerSupabase()
  const { data } = await supabase
    .from('surveys')
    .select('id, title, description, url, min_age, max_age')
    .eq('is_published', true)
    .in('audience', [audience, 'all'])
    .order('published_at', { ascending: false })
  const surveys = (data ?? []) as SurveyRow[]
  if (surveys.length === 0) return null

  let q = supabase.from('survey_dismissals').select('survey_id').eq('user_id', user.id)
  q = child ? q.eq('child_id', child.id) : q.is('child_id', null)
  const { data: dismissed } = await q
  const done = new Set((dismissed ?? []).map(d => d.survey_id as string))

  const match = surveys.find(s => {
    if (done.has(s.id)) return false
    if (child) {
      if (s.min_age != null && child.age < s.min_age) return false
      if (s.max_age != null && child.age > s.max_age) return false
    }
    return true
  })
  if (!match) return null

  const verified = match.url.includes('__TOKEN__')
  const url = verified
    ? match.url.replace('__TOKEN__', makeToken({ surveyId: match.id, userId: user.id, childId: child?.id ?? null }))
    : match.url

  return { id: match.id, title: match.title, description: match.description, url, verified }
}
