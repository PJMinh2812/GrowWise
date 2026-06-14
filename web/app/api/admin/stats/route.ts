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

  // Auto-expire pending transactions older than 15 minutes
  const cutoff = new Date(now.getTime() - 15 * 60 * 1000).toISOString()
  await admin
    .from('payment_transactions')
    .update({ status: 'cancelled', updated_at: now.toISOString() })
    .eq('status', 'pending')
    .lt('created_at', cutoff)

  // 1. All app users (auth.users)
  const { data: { users: allUsers } } = await admin.auth.admin.listUsers({ perPage: 1000 })
  const totalUsers = allUsers.length
  const newUsersThisMonth = allUsers.filter(u => u.created_at >= startOfMonth).length

  // 2. Subscriptions (NOTE: live user_subscriptions has no billing_interval column)
  const { data: subs } = await admin
    .from('user_subscriptions')
    .select('status, plan:plans(name, display_name)')

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

  // 3b. Completed transactions over the last 6 months → revenue chart + sales by plan
  const sixMonthsAgo = new Date(now.getFullYear(), now.getMonth() - 5, 1).toISOString()
  const { data: completedTxns } = await admin
    .from('payment_transactions')
    .select('amount, plan_name, created_at')
    .eq('status', 'completed')
    .gte('created_at', sixMonthsAgo)

  // Revenue by month: build 6 buckets (oldest → newest), fill from completedTxns
  const monthBuckets: { month: string; revenue: number; count: number }[] = []
  const bucketIndex: Record<string, number> = {}
  for (let i = 5; i >= 0; i--) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1)
    const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
    bucketIndex[key] = monthBuckets.length
    monthBuckets.push({ month: key, revenue: 0, count: 0 })
  }
  const planAgg: Record<string, { plan: string; count: number; revenue: number }> = {}
  completedTxns?.forEach(t => {
    const d = new Date(t.created_at)
    const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
    const idx = bucketIndex[key]
    if (idx !== undefined) {
      monthBuckets[idx].revenue += t.amount ?? 0
      monthBuckets[idx].count += 1
    }
    const name = t.plan_name ?? 'unknown'
    if (!planAgg[name]) planAgg[name] = { plan: name, count: 0, revenue: 0 }
    planAgg[name].count += 1
    planAgg[name].revenue += t.amount ?? 0
  })
  const revenueByMonth = monthBuckets
  const salesByPlan = Object.values(planAgg).sort((a, b) => b.revenue - a.revenue)

  // 4. Recent 10 transactions (all time)
  const { data: recentTxns } = await admin
    .from('payment_transactions')
    .select('order_id, plan_name, amount, status, provider, billing_interval, created_at, user_id')
    .order('created_at', { ascending: false })
    .limit(10)

  // Attach emails to recent transactions
  const userEmailMap = Object.fromEntries(allUsers.map(u => [u.id, u.email ?? '']))
  const recentWithEmail = recentTxns?.map(t => ({ ...t, email: userEmailMap[t.user_id] ?? '' })) ?? []

  // 5. Subscribers per plan (active count; revenue comes from salesByPlan)
  const planMap: Record<string, { name: string; display_name: string; subscribers: number; free: number }> = {}
  subs?.forEach(s => {
    const plan = (s.plan as unknown) as { name: string; display_name: string } | null
    if (!plan) return
    if (!planMap[plan.name]) planMap[plan.name] = { name: plan.name, display_name: plan.display_name, subscribers: 0, free: 0 }
    if (s.status === 'active') planMap[plan.name].subscribers++
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
    salesByPlan,
    revenueByMonth,
    recentTxns:   recentWithEmail,
  })
}
