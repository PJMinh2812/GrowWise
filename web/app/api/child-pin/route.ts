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

/**
 * PATCH { childId, currentPin, newPin } → child self-changes their own PIN.
 * Authenticates via the gw_child_id cookie (no parent session needed).
 * If currentPin is empty string and child has no PIN, this sets a fresh PIN.
 */
export async function PATCH(request: Request) {
  const { childId, currentPin, newPin } = await request.json()
  if (!childId || !isValidPin(newPin)) {
    return NextResponse.json({ error: 'PIN mới phải gồm 4 chữ số' }, { status: 400 })
  }

  // Verify the request is coming from the child's own session (cookie check)
  const { cookies } = await import('next/headers')
  const cookieStore = await cookies()
  const sessionChildId = cookieStore.get('gw_child_id')?.value
  if (sessionChildId !== childId) {
    return NextResponse.json({ error: 'forbidden' }, { status: 403 })
  }

  const admin = createAdminClient()
  const { data } = await admin
    .from('children')
    .select('child_pin_hash')
    .eq('id', childId)
    .maybeSingle()

  // If child already has a PIN, verify currentPin first
  if (data?.child_pin_hash) {
    if (!isValidPin(currentPin) || data.child_pin_hash !== hashPin(childId, currentPin)) {
      return NextResponse.json({ ok: false, error: 'Mã PIN hiện tại không đúng' })
    }
  }

  const { error } = await admin
    .from('children')
    .update({ child_pin_hash: hashPin(childId, newPin) })
    .eq('id', childId)

  if (error) return NextResponse.json({ error: error.message }, { status: 500 })
  return NextResponse.json({ ok: true })
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
