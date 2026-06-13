import { NextResponse } from 'next/server'
import crypto from 'crypto'
import { createServerSupabase } from '@/lib/supabase-server'
import { createAdminClient } from '@/lib/supabase-admin'

export const runtime = 'nodejs'

function hashPin(childId: string, pin: string): string {
  return crypto.createHash('sha256').update(`${childId}:${pin}`).digest('hex')
}

function isValidPin(pin: unknown): pin is string {
  return typeof pin === 'string' && /^\d{4}$/.test(pin)
}

async function getUserId(): Promise<string | null> {
  const supabase = await createServerSupabase()
  const { data: { user } } = await supabase.auth.getUser()
  return user?.id ?? null
}

async function getChildOwnerId(childId: string): Promise<string | null> {
  const admin = createAdminClient()
  const { data } = await admin
    .from('children')
    .select('families(parent_id)')
    .eq('id', childId)
    .maybeSingle()
  const fam = data?.families as unknown as { parent_id: string } | null
  return fam?.parent_id ?? null
}

/** GET ?childId= → whether that child has a PIN */
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const childId = searchParams.get('childId')
  if (!childId) return NextResponse.json({ error: 'missing childId' }, { status: 400 })

  const admin = createAdminClient()
  const { data } = await admin
    .from('children')
    .select('child_pin_hash')
    .eq('id', childId)
    .maybeSingle()

  return NextResponse.json({ hasPin: Boolean(data?.child_pin_hash) })
}

/** POST { childId, pin } → set / change PIN (parent only) */
export async function POST(request: Request) {
  const userId = await getUserId()
  if (!userId) return NextResponse.json({ error: 'unauthorized' }, { status: 401 })

  const { childId, pin } = await request.json()
  if (!childId || !isValidPin(pin)) {
    return NextResponse.json({ error: 'PIN phải gồm 4 chữ số' }, { status: 400 })
  }

  const owner = await getChildOwnerId(childId)
  if (owner !== userId) return NextResponse.json({ error: 'forbidden' }, { status: 403 })

  const admin = createAdminClient()
  const { error } = await admin
    .from('children')
    .update({ child_pin_hash: hashPin(childId, pin) })
    .eq('id', childId)

  if (error) return NextResponse.json({ error: error.message }, { status: 500 })
  return NextResponse.json({ ok: true })
}

/** PUT { childId, pin } → verify PIN (role picker) */
export async function PUT(request: Request) {
  const userId = await getUserId()
  if (!userId) return NextResponse.json({ error: 'unauthorized' }, { status: 401 })

  const { childId, pin } = await request.json()
  if (!childId || !isValidPin(pin)) {
    return NextResponse.json({ ok: false }, { status: 400 })
  }

  const admin = createAdminClient()
  const { data } = await admin
    .from('children')
    .select('child_pin_hash')
    .eq('id', childId)
    .maybeSingle()

  const ok = Boolean(data?.child_pin_hash) && data!.child_pin_hash === hashPin(childId, pin)
  return NextResponse.json({ ok })
}

/** DELETE { childId } → remove PIN (parent only) */
export async function DELETE(request: Request) {
  const userId = await getUserId()
  if (!userId) return NextResponse.json({ error: 'unauthorized' }, { status: 401 })

  const { childId } = await request.json()
  if (!childId) return NextResponse.json({ error: 'missing childId' }, { status: 400 })

  const owner = await getChildOwnerId(childId)
  if (owner !== userId) return NextResponse.json({ error: 'forbidden' }, { status: 403 })

  const admin = createAdminClient()
  const { error } = await admin
    .from('children')
    .update({ child_pin_hash: null })
    .eq('id', childId)

  if (error) return NextResponse.json({ error: error.message }, { status: 500 })
  return NextResponse.json({ ok: true })
}
