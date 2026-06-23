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

  // Lấy tất cả subscriptions kèm plan info
  const { data: subs, error } = await admin
    .from('user_subscriptions')
    .select('*, plan:plans(name, display_name, price_monthly)')
    .order('created_at', { ascending: false })

  if (error) return NextResponse.json({ error: error.message }, { status: 500 })

  // Lấy emails từ auth.users
  const { data: { users } } = await admin.auth.admin.listUsers({ perPage: 1000 })
  const emailMap = Object.fromEntries(users.map(u => [u.id, u.email ?? '']))

  const result = subs?.map(s => ({ ...s, email: emailMap[s.user_id] ?? '' }))

  // Tính revenue tháng này
  const now = new Date()
  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1)
  const monthlyRevenue = subs
    ?.filter(s => s.status === 'active' && new Date(s.created_at) >= startOfMonth)
    .reduce((sum, s) => {
      const plan = s.plan as { price_monthly?: number } | null
      return sum + (plan?.price_monthly ?? 0)
    }, 0) ?? 0

  return NextResponse.json({ subscriptions: result, monthly_revenue: monthlyRevenue })
}

// PATCH: admin có thể cancel subscription của user
export async function PATCH(request: NextRequest) {
  const ok = await verifyAdmin(request)
  if (!ok) return NextResponse.json({ error: 'Forbidden' }, { status: 403 })

  const { id, status } = await request.json()
  if (!id || !status) return NextResponse.json({ error: 'id và status bắt buộc' }, { status: 400 })

  const admin = createAdminClient()
  const { data, error } = await admin
    .from('user_subscriptions')
    .update({ status })
    .eq('id', id)
    .select()
    .single()

  if (error) return NextResponse.json({ error: error.message }, { status: 500 })
  return NextResponse.json(data)
}
