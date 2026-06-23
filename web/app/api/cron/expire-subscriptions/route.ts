import { NextRequest, NextResponse } from 'next/server'
import { createAdminClient } from '@/lib/supabase-admin'

/**
 * Background expiry so the admin dashboard / revenue stay accurate even when a
 * user doesn't open the app (per-request expiry in lib/app/subscription.ts
 * still gates access). Marks lapsed paid/trial subscriptions as `expired`;
 * subscriptions with a scheduled change are left for the on-read handler to
 * switch (it needs to start a fresh period for the new plan).
 */
export async function GET(request: NextRequest) {
  const authHeader = request.headers.get('authorization')
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const supabase = createAdminClient()
  const now = new Date().toISOString()

  const { data, error } = await supabase
    .from('user_subscriptions')
    .update({ status: 'expired' })
    .in('status', ['active', 'trial'])
    .is('scheduled_plan_name', null)
    .lt('current_period_end', now)
    .select('user_id')

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json({ expired: data?.length ?? 0 })
}
