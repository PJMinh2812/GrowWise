import crypto from 'crypto'

export interface SurveyTokenPayload {
  surveyId: string
  userId: string
  childId: string | null
}

function secret(): string {
  return process.env.SURVEY_TOKEN_SECRET || process.env.SUPABASE_SERVICE_ROLE_KEY || 'growwise-survey-dev'
}

function sign(payloadB64: string): string {
  return crypto.createHmac('sha256', secret()).update(payloadB64).digest('base64url')
}

/** Signed token (payload.signature) carried through the Google Form. */
export function makeToken(p: SurveyTokenPayload): string {
  const payloadB64 = Buffer.from(JSON.stringify(p)).toString('base64url')
  return `${payloadB64}.${sign(payloadB64)}`
}

/** Verify signature and return the payload, or null if invalid/tampered. */
export function verifyToken(token: string): SurveyTokenPayload | null {
  const [payloadB64, sig] = (token ?? '').split('.')
  if (!payloadB64 || !sig) return null
  const expected = sign(payloadB64)
  // constant-time compare
  const a = Buffer.from(sig)
  const b = Buffer.from(expected)
  if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) return null
  try {
    const obj = JSON.parse(Buffer.from(payloadB64, 'base64url').toString())
    if (!obj?.surveyId || !obj?.userId) return null
    return { surveyId: obj.surveyId, userId: obj.userId, childId: obj.childId ?? null }
  } catch {
    return null
  }
}
