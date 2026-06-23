import { createClient } from '@supabase/supabase-js';

function adminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
  );
}

/**
 * Activate the subscription for a paid order — idempotent and session-free.
 * Reads the transaction (user_id, plan_name, billing_interval), looks up the
 * plan, upserts user_subscriptions, and marks the transaction completed.
 * Safe to call multiple times (from webhook, status poll, or result page).
 * Returns true if the subscription is active afterwards.
 */
export async function activateSubscriptionForOrder(
  orderId: string,
  paymentMethod: string = 'sepay',
): Promise<boolean> {
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

  // Early renewal of the SAME plan stacks onto the remaining time instead of
  // discarding it; otherwise the new period starts now.
  const { data: existing } = await supabase
    .from('user_subscriptions')
    .select('status, plan_id, current_period_end')
    .eq('user_id', tx.user_id)
    .maybeSingle();
  let base = now;
  if (
    existing &&
    existing.status === 'active' &&
    existing.plan_id === plan.id &&
    existing.current_period_end &&
    new Date(existing.current_period_end) > now
  ) {
    base = new Date(existing.current_period_end);
  }
  const periodEnd = new Date(base.getTime() + days * 24 * 60 * 60 * 1000);

  const { error: subErr } = await supabase.from('user_subscriptions').upsert(
    {
      user_id: tx.user_id,
      plan_id: plan.id,
      status: 'active',
      billing_interval: tx.billing_interval,
      trial_ends_at: null,
      current_period_start: now.toISOString(),
      current_period_end: periodEnd.toISOString(),
      payment_method: paymentMethod,
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
