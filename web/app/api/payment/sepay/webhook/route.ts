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
    const expected = process.env.SEPAY_WEBHOOK_API_KEY?.trim();
    // SePay sends `Authorization: Apikey <key>`. Be tolerant of the scheme
    // (Apikey/Bearer) and of a raw key, so a config mismatch in the dashboard
    // doesn't silently 401 when the key itself is correct.
    const auth = (request.headers.get('authorization') ?? '').trim();
    const provided = auth.replace(/^(apikey|bearer)\s+/i, '').trim();
    if (!expected || provided !== expected) {
      console.warn('[SePay Webhook] unauthorized', {
        hasExpected: Boolean(expected),
        gotScheme: auth.split(/\s+/)[0] ?? '',
        match: provided === expected,
      });
      return NextResponse.json({ message: 'Unauthorized' }, { status: 401 });
    }

    const body = await request.json();
    const transferType   = body.transferType as string | undefined;
    const transferAmount = Number(body.transferAmount ?? 0);
    // SePay sends the matched `code` (if a prefix is configured) and the full
    // `content`; check both so we don't depend on dashboard config.
    const rawText        = `${body.code ?? ''} ${body.content ?? ''}`.toUpperCase();
    const referenceCode  = body.referenceCode ? String(body.referenceCode) : null;

    // Only incoming transfers can pay for an order.
    if (transferType && transferType !== 'in') {
      return NextResponse.json({ message: 'Ignored (not an incoming transfer)' });
    }

    // Extract our order code (GW + digits); tolerant of spaces/case.
    const match = rawText.replace(/\s+/g, '').match(/GW\d+/);
    if (!match) {
      console.warn('[SePay Webhook] no order code in content', { content: body.content, code: body.code });
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
      console.warn('[SePay Webhook] order not found', { orderId });
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

    const result = await activateSubscriptionForOrder(orderId, 'sepay');
    if (!result.ok) {
      console.error('[SePay Webhook] activation failed', { orderId, error: result.error });
      // Reply 200 so SePay doesn't retry forever, but surface the reason in the
      // response body so it shows up in the SePay delivery log.
      return NextResponse.json({ message: 'Activation failed', error: result.error });
    }

    return NextResponse.json({ message: 'OK', orderId });
  } catch (e) {
    console.error('[SePay Webhook]', e);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
