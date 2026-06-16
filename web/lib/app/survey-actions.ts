'use server'

import { createServerSupabase } from '@/lib/supabase-server'
import { getCurrentUser } from '@/lib/app/auth'

/** Mark a survey as done for the current subject so its banner stops showing. */
export async function dismissSurvey(surveyId: string, childId?: string | null) {
  const user = await getCurrentUser()
  if (!user) return { ok: false }

  const supabase = await createServerSupabase()
  // Insert; ignore duplicate (already dismissed) — harmless for the "done" check.
  const { error } = await supabase
    .from('survey_dismissals')
    .insert({ survey_id: surveyId, user_id: user.id, child_id: childId ?? null })
  if (error && error.code !== '23505') return { ok: false, error: error.message }
  return { ok: true }
}
