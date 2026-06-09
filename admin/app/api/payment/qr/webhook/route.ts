import { NextResponse } from 'next/server';
import { PayOS } from '@payos/node';
import type { Webhook } from '@payos/node/lib/resources/webhooks/webhook';
import { createClient } from '@supabase/supabase-js';

const payos = new PayOS();

export async function POST(request: Request) {
  try {
    const body = (await request.json()) as Webhook;

    let webhookData: Awaited<ReturnType<typeof payos.webhooks.verify>>;
    try {
      webhookData = await payos.webhooks.verify(body);
    } catch {
      return NextResponse.json({ message: 'Invalid signature' }, { status: 400 });
    }

    const isSuccess = body.code === '00';
    const status    = isSuccess ? 'completed' : 'failed';
    const orderCode = webhookData.orderCode;

    const supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!,
    );

    const { data: txn } = await supabase
      .from('payment_transactions')
      .select('order_id, user_id, plan_name, billing_interval')
      .eq('provider_transaction_id', String(orderCode))
      .eq('provider', 'payos')
      .single();

    if (!txn) {
      return NextResponse.json({ message: 'Order not found' }, { status: 404 });
    }

    await supabase
      .from('payment_transactions')
      .update({ status, updated_at: new Date().toISOString() })
      .eq('order_id', txn.order_id);

    if (isSuccess) {
      const { data: plan } = await supabase
        .from('plans')
        .select('id')
        .eq('name', txn.plan_name)
        .single();

      if (plan) {
        const now       = new Date();
        const days      = txn.billing_interval === 'yearly' ? 365 : 30;
        const periodEnd = new Date(now.getTime() + days * 24 * 60 * 60 * 1000);

        await supabase.from('user_subscriptions').upsert(
          {
            user_id:              txn.user_id,
            plan_id:              plan.id,
            status:               'active',
            billing_interval:     txn.billing_interval,
            trial_ends_at:        null,
            current_period_start: now.toISOString(),
            current_period_end:   periodEnd.toISOString(),
            payment_method:       'payos',
          },
          { onConflict: 'user_id' },
        );
      }
    }

    return NextResponse.json({ message: 'OK' });
  } catch (e) {
    console.error('[PayOS Webhook]', e);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
