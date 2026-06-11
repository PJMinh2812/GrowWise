import { createServerClient } from '@supabase/ssr'
import { createAdminClient } from '@/lib/supabase-admin'
import { NextRequest, NextResponse } from 'next/server'

async function verifyAdmin(request: NextRequest): Promise<boolean> {
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies: { getAll: () => request.cookies.getAll(), setAll: () => {} } }
  )
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return false

  const admin = createAdminClient()
  const { data: profile } = await admin.from('admin_profiles').select('role').eq('id', user.id).single()
  const adminEmails = (process.env.ADMIN_EMAILS ?? '').split(',').map(e => e.trim())

  return profile?.role === 'admin' || adminEmails.includes(user.email ?? '')
}

export async function GET(request: NextRequest) {
  const ok = await verifyAdmin(request)
  if (!ok) return NextResponse.json({ error: 'Forbidden' }, { status: 403 })

  const admin = createAdminClient()
  const { data, error } = await admin.from('plans').select('*').order('price_monthly')
  if (error) return NextResponse.json({ error: error.message }, { status: 500 })

  // Thêm subscriber count vào mỗi plan
  const { data: subs } = await admin.from('user_subscriptions').select('plan_id, status')
  const countMap: Record<string, number> = {}
  subs?.forEach(s => {
    if (s.status === 'active' || s.status === 'trial') {
      countMap[s.plan_id] = (countMap[s.plan_id] ?? 0) + 1
    }
  })

  const plans = data?.map(p => ({ ...p, subscriber_count: countMap[p.id] ?? 0 }))
  return NextResponse.json(plans)
}

export async function PATCH(request: NextRequest) {
  const ok = await verifyAdmin(request)
  if (!ok) return NextResponse.json({ error: 'Forbidden' }, { status: 403 })

  const { id, price_monthly, price_yearly, is_active, display_name } = await request.json()
  if (!id) return NextResponse.json({ error: 'id bắt buộc' }, { status: 400 })

  const admin = createAdminClient()
  const update: Record<string, unknown> = {}
  if (price_monthly !== undefined) update.price_monthly = price_monthly
  if (price_yearly  !== undefined) update.price_yearly  = price_yearly
  if (is_active     !== undefined) update.is_active     = is_active
  if (display_name  !== undefined && display_name.trim()) update.display_name = display_name.trim()

  const { data, error } = await admin.from('plans').update(update).eq('id', id).select().single()
  if (error) return NextResponse.json({ error: error.message }, { status: 500 })

  return NextResponse.json(data)
}
