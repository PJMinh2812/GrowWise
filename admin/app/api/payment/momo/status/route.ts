import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const orderId = searchParams.get('orderId');

  if (!orderId) {
    return NextResponse.json({ error: 'Missing orderId' }, { status: 400 });
  }

  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  );

  const { data, error } = await supabase
    .from('payment_transactions')
    .select('status, created_at')
    .eq('order_id', orderId)
    .single();

  if (error || !data) {
    return NextResponse.json({ error: 'Order not found' }, { status: 404 });
  }

  if (data.status === 'pending') {
    const ageMs = Date.now() - new Date(data.created_at).getTime()
    if (ageMs > 15 * 60 * 1000) {
      await supabase
        .from('payment_transactions')
        .update({ status: 'cancelled', updated_at: new Date().toISOString() })
        .eq('order_id', orderId)
      return NextResponse.json({ status: 'cancelled' })
    }
  }

  return NextResponse.json({ status: data.status });
}
