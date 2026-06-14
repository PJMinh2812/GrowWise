import crypto from 'crypto';
import { createClient } from '@supabase/supabase-js';

const PARTNER_CODE = process.env.MOMO_PARTNER_CODE ?? 'MOMOBKUN20180529';
const ACCESS_KEY = process.env.MOMO_ACCESS_KEY ?? 'klm05TvNBzhg7h7j';
const SECRET_KEY = process.env.MOMO_SECRET_KEY ?? 'at67qH6mk8w5Y1nAyMoYKMWACiEi2bsa';
const QUERY_ENDPOINT =
  process.env.MOMO_QUERY_ENDPOINT ?? 'https://test-payment.momo.vn/v2/gateway/api/query';

/** MoMo resultCodes that mean "still waiting on the user" (not a final failure). */
export const MOMO_PENDING_CODES = [1000, 7000, 7002, 9000];

function adminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
  );
}

/**
 * Ask MoMo directly for the real status of an order, instead of waiting on the
 * IPN (which is unreliable in sandbox / when the deploy URL isn't reachable).
 * Returns the numeric resultCode, or null on any error.
 */
export async function queryMomoResultCode(orderId: string): Promise<number | null> {
  try {
    const requestId = `${orderId}-q${Date.now()}`;
    const rawSignature = `accessKey=${ACCESS_KEY}&orderId=${orderId}&partnerCode=${PARTNER_CODE}&requestId=${requestId}`;
    const signature = crypto.createHmac('sha256', SECRET_KEY).update(rawSignature).digest('hex');

    const res = await fetch(QUERY_ENDPOINT, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ partnerCode: PARTNER_CODE, requestId, orderId, lang: 'vi', signature }),
    });
    const json = await res.json();
    return typeof json.resultCode === 'number' ? json.resultCode : null;
  } catch (e) {
    console.error('[MoMo query]', e);
    return null;
  }
}

/**
 * Activate the subscription for a paid order — idempotent and session-free.
 * Reads the transaction (user_id, plan_name, billing_interval), looks up the
 * plan, upserts user_subscriptions, and marks the transaction completed.
 * Safe to call multiple times (from IPN, status poll, or result page).
 * Returns true if the subscription is active afterwards.
 */
export async function activateSubscriptionForOrder(orderId: string): Promise<boolean> {
  const supabase = adminClient();

  const { data: tx, error: txErr } = await supabase
    .from('payment_transactions')
    .select('user_id, plan_name, billing_interval')
    .eq('order_id', orderId)
    .single();
  if (txErr || !tx) {
    console.error('[activateSubscription] transaction not found:', orderId, txErr);
    return false;
  }

  const { data: plan } = await supabase
    .from('plans')
    .select('id')
    .eq('name', tx.plan_name)
    .single();
  if (!plan) {
    console.error('[activateSubscription] plan not found:', tx.plan_name);
    return false;
  }

  const now = new Date();
  const days = tx.billing_interval === 'yearly' ? 365 : 30;
  const periodEnd = new Date(now.getTime() + days * 24 * 60 * 60 * 1000);

  const { error: subErr } = await supabase.from('user_subscriptions').upsert(
    {
      user_id: tx.user_id,
      plan_id: plan.id,
      status: 'active',
      trial_ends_at: null,
      current_period_start: now.toISOString(),
      current_period_end: periodEnd.toISOString(),
      payment_method: 'momo',
    },
    { onConflict: 'user_id' },
  );
  if (subErr) {
    console.error('[activateSubscription] upsert failed:', subErr);
    return false;
  }

  // A paid upgrade cancels any pending scheduled downgrade (best-effort; the
  // column may not exist yet on older DBs, so ignore any error).
  await supabase
    .from('user_subscriptions')
    .update({ scheduled_plan_name: null })
    .eq('user_id', tx.user_id);

  await supabase
    .from('payment_transactions')
    .update({ status: 'completed', updated_at: new Date().toISOString() })
    .eq('order_id', orderId);

  return true;
}
