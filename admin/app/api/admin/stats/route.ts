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
  const now = new Date()
  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1).toISOString()

  // 1. All app users (auth.users)
  const { data: { users: allUsers } } = await admin.auth.admin.listUsers({ perPage: 1000 })
  const totalUsers = allUsers.length
  const newUsersThisMonth = allUsers.filter(u => u.created_at >= startOfMonth).length

  // 2. Subscriptions
  const { data: subs } = await admin
    .from('user_subscriptions')
    .select('status, billing_interval, plan:plans(name, display_name, price_monthly, price_yearly)')

  const activeSubs   = subs?.filter(s => s.status === 'active') ?? []
  const trialSubs    = subs?.filter(s => s.status === 'trial') ?? []
  const canceledSubs = subs?.filter(s => s.status === 'canceled') ?? []

  // 3. Monthly revenue from completed payment_transactions this month
  const { data: txns } = await admin
    .from('payment_transactions')
    .select('amount, status, provider, plan_name, billing_interval, created_at, order_id')
    .eq('status', 'completed')
    .gte('created_at', startOfMonth)
    .order('created_at', { ascending: false })

  const monthlyRevenue = txns?.reduce((sum, t) => sum + (t.amount ?? 0), 0) ?? 0

  // 4. Recent 10 transactions (all time)
  const { data: recentTxns } = await admin
    .from('payment_transactions')
    .select('order_id, plan_name, amount, status, provider, billing_interval, created_at, user_id')
    .order('created_at', { ascending: false })
    .limit(10)

  // Attach emails to recent transactions
  const userEmailMap = Object.fromEntries(allUsers.map(u => [u.id, u.email ?? '']))
  const recentWithEmail = recentTxns?.map(t => ({ ...t, email: userEmailMap[t.user_id] ?? '' })) ?? []

  // 5. Subscribers per plan
  const planMap: Record<string, { display_name: string; monthly: number; yearly: number; free: number }> = {}
  subs?.forEach(s => {
    const plan = (s.plan as unknown) as { name: string; display_name: string } | null
    if (!plan) return
    if (!planMap[plan.name]) planMap[plan.name] = { display_name: plan.display_name, monthly: 0, yearly: 0, free: 0 }
    if (s.status === 'active') {
      if (s.billing_interval === 'yearly') planMap[plan.name].yearly++
      else if (s.billing_interval === 'monthly') planMap[plan.name].monthly++
    }
    if (plan.name === 'free') planMap[plan.name].free++
  })

  return NextResponse.json({
    totalUsers,
    newUsersThisMonth,
    monthlyRevenue,
    activeSubs:   activeSubs.length,
    trialSubs:    trialSubs.length,
    canceledSubs: canceledSubs.length,
    planSummary:  Object.values(planMap),
    recentTxns:   recentWithEmail,
  })
}
