import { NextResponse } from 'next/server'
import crypto from 'crypto'
import { createServerSupabase } from '@/lib/supabase-server'
import { createAdminClient } from '@/lib/supabase-admin'

export const runtime = 'nodejs'

function hashPin(userId: string, pin: string): string {
  return crypto.createHash('sha256').update(`${userId}:${pin}`).digest('hex')
}

function isValidPin(pin: unknown): pin is string {
  return typeof pin === 'string' && /^\d{4}$/.test(pin)
}

async function getUserId(): Promise<string | null> {
  const supabase = await createServerSupabase()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  return user?.id ?? null
}

/** GET → whether the logged-in parent already has a PIN set. */
export async function GET() {
  const userId = await getUserId()
  if (!userId) return NextResponse.json({ error: 'unauthorized' }, { status: 401 })

  const admin = createAdminClient()
  const { data } = await admin
    .from('profiles')
    .select('parent_pin_hash')
    .eq('id', userId)
    .maybeSingle()

  return NextResponse.json({ hasPin: Boolean(data?.parent_pin_hash) })
}

/** POST { pin } → set / overwrite the parent PIN. */
export async function POST(request: Request) {
  const userId = await getUserId()
  if (!userId) return NextResponse.json({ error: 'unauthorized' }, { status: 401 })

  const { pin } = await request.json()
  if (!isValidPin(pin)) {
    return NextResponse.json({ error: 'PIN phải gồm 4 chữ số' }, { status: 400 })
  }

  const admin = createAdminClient()
  const { error } = await admin
    .from('profiles')
    .update({ parent_pin_hash: hashPin(userId, pin) })
    .eq('id', userId)

  if (error) return NextResponse.json({ error: error.message }, { status: 500 })
  return NextResponse.json({ ok: true })
}

/** PUT { pin } → verify the parent PIN. */
export async function PUT(request: Request) {
  const userId = await getUserId()
  if (!userId) return NextResponse.json({ error: 'unauthorized' }, { status: 401 })

  const { pin } = await request.json()
  if (!isValidPin(pin)) {
    return NextResponse.json({ ok: false }, { status: 400 })
  }

  const admin = createAdminClient()
  const { data } = await admin
    .from('profiles')
    .select('parent_pin_hash')
    .eq('id', userId)
    .maybeSingle()

  const ok = Boolean(data?.parent_pin_hash) && data!.parent_pin_hash === hashPin(userId, pin)
  return NextResponse.json({ ok })
}
