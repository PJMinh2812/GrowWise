import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import { activateSubscriptionForOrder } from '@/lib/payment/subscription';

/**
 * SePay webhook — called when money lands in the linked bank account.
 * Authenticated with an API key configured in the SePay dashboard, sent as
 * `Authorization: Apikey <key>`.
 *
 * Payload (relevant fields): { transferType: 'in'|'out', transferAmount,
 * content, referenceCode, id, ... }. We always reply 200 on handled events so
 * SePay doesn't retry forever.
 */
export async function POST(request: Request) {
  try {
    const expected = process.env.SEPAY_WEBHOOK_API_KEY;
    const auth = request.headers.get('authorization') ?? '';
    if (!expected || auth !== `Apikey ${expected}`) {
      return NextResponse.json({ message: 'Unauthorized' }, { status: 401 });
    }

    const body = await request.json();
    const transferType   = body.transferType as string | undefined;
    const transferAmount = Number(body.transferAmount ?? 0);
    const content        = String(body.content ?? '');
    const referenceCode  = body.referenceCode ? String(body.referenceCode) : null;

    // Only incoming transfers can pay for an order.
    if (transferType !== 'in') {
      return NextResponse.json({ message: 'Ignored (not an incoming transfer)' });
    }

    // Extract our order code (GW + digits) from the transfer content.
    const match = content.match(/GW\d+/);
    if (!match) {
      return NextResponse.json({ message: 'No order code in content' });
    }
    const orderId = match[0];

    const supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!,
    );

    const { data: txn } = await supabase
      .from('payment_transactions')
      .select('order_id, amount, status')
      .eq('order_id', orderId)
      .eq('provider', 'sepay')
      .single();

    if (!txn) {
      return NextResponse.json({ message: 'Order not found' });
    }

    // Already processed — idempotent ack.
    if (txn.status === 'completed') {
      return NextResponse.json({ message: 'Already completed' });
    }

    // Guard against underpayment.
    if (transferAmount < txn.amount) {
      console.warn('[SePay Webhook] underpaid', { orderId, transferAmount, expected: txn.amount });
      return NextResponse.json({ message: 'Amount mismatch' });
    }

    if (referenceCode) {
      await supabase
        .from('payment_transactions')
        .update({ provider_transaction_id: referenceCode, updated_at: new Date().toISOString() })
        .eq('order_id', orderId);
    }

    await activateSubscriptionForOrder(orderId, 'sepay');

    return NextResponse.json({ message: 'OK' });
  } catch (e) {
    console.error('[SePay Webhook]', e);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
