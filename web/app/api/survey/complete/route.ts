import { NextRequest, NextResponse } from 'next/server'
import { createAdminClient } from '@/lib/supabase-admin'
import { verifyToken } from '@/lib/app/survey-token'

export const runtime = 'nodejs'

/**
 * Public webhook called by the Google Form's onFormSubmit Apps Script trigger.
 * Body: { token } — a signed token carrying { surveyId, userId, childId }.
 * On a valid token we record a dismissal so the survey banner stops showing
 * for that subject (i.e. only after a REAL form submission). Secured by the
 * token's HMAC signature, so no session is required.
 */
export async function POST(req: NextRequest) {
  let token = ''
  try {
    const body = await req.json()
    token = body?.token ?? ''
  } catch {
    // Apps Script may post form-encoded; try that too
    try {
      const form = await req.formData()
      token = String(form.get('token') ?? '')
    } catch {
      /* ignore */
    }
  }

  const payload = verifyToken(token)
  if (!payload) return NextResponse.json({ error: 'invalid token' }, { status: 401 })

  const supabase = createAdminClient()
  const { error } = await supabase.from('survey_dismissals').insert({
    survey_id: payload.surveyId,
    user_id: payload.userId,
    child_id: payload.childId,
  })
  if (error && error.code !== '23505') {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
  return NextResponse.json({ ok: true })
}
