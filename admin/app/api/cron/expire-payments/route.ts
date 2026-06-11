import { NextRequest, NextResponse } from 'next/server'
import { createAdminClient } from '@/lib/supabase-admin'

const EXPIRE_AFTER_MINUTES = 15

export async function GET(request: NextRequest) {
  const authHeader = request.headers.get('authorization')
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const supabase = createAdminClient()
  const cutoff = new Date(Date.now() - EXPIRE_AFTER_MINUTES * 60 * 1000).toISOString()

  const { data, error } = await supabase
    .from('payment_transactions')
    .update({ status: 'cancelled', updated_at: new Date().toISOString() })
    .eq('status', 'pending')
    .lt('created_at', cutoff)
    .select('order_id, provider, amount')

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json({
    cancelled: data?.length ?? 0,
    orders: data?.map(r => r.order_id),
  })
}
