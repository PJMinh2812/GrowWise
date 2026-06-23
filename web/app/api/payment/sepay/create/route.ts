import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import { effectiveYearly } from '@/lib/app/pricing-utils';

// SePay bank account that money is transferred to (linked in the SePay dashboard).
const SEPAY_ACCOUNT      = process.env.SEPAY_ACCOUNT ?? '';
const SEPAY_BANK         = process.env.SEPAY_BANK ?? '';
const SEPAY_ACCOUNT_NAME = process.env.SEPAY_ACCOUNT_NAME ?? '';

export async function POST(request: Request) {
  try {
    const { userId, planName, billingInterval } = await request.json();

    if (!userId || !planName || !billingInterval) {
      return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
    }

    if (!SEPAY_ACCOUNT || !SEPAY_BANK) {
      return NextResponse.json({ error: 'SePay chưa được cấu hình' }, { status: 500 });
    }

    const supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!,
    );

    const { data: plan, error: planErr } = await supabase
      .from('plans')
      .select('id, price_monthly, price_yearly, display_name')
      .eq('name', planName)
      .single();

    if (planErr || !plan) {
      return NextResponse.json({ error: 'Plan not found' }, { status: 404 });
    }

    const amount: number =
      billingInterval === 'yearly'
        ? effectiveYearly(plan.price_monthly)
        : plan.price_monthly;

    // Order code embedded in the bank-transfer content; uppercase alphanumeric
    // so it survives banks normalising the transfer description. The webhook
    // matches the incoming transfer back to this order by finding `GW<digits>`.
    const orderCode = Number(String(Date.now()).slice(-9));
    const orderId   = `GW${orderCode}`;
    const description = orderId;

    // SePay renders a VietQR image directly — no API call needed to create it.
    const qrCode =
      `https://qr.sepay.vn/img?acc=${encodeURIComponent(SEPAY_ACCOUNT)}` +
      `&bank=${encodeURIComponent(SEPAY_BANK)}` +
      `&amount=${amount}` +
      `&des=${encodeURIComponent(description)}`;

    const { error: insErr } = await supabase.from('payment_transactions').insert({
      order_id:                orderId,
      user_id:                 userId,
      plan_name:               planName,
      billing_interval:        billingInterval,
      amount,
      status:                  'pending',
      provider:                'sepay',
      provider_transaction_id: description,
    });
    if (insErr) {
      // Most likely the DB CHECK constraint hasn't been migrated to allow
      // provider='sepay' (run supabase_sepay.sql). Surface it instead of
      // returning a QR for an order the webhook can never find.
      console.error('[SePay Create] insert failed', insErr);
      return NextResponse.json({ error: 'Không tạo được đơn (DB): ' + insErr.message }, { status: 500 });
    }

    return NextResponse.json({
      orderId,
      orderCode,
      qrCode,
      amount,
      description,
      accountNumber: SEPAY_ACCOUNT,
      accountName:   SEPAY_ACCOUNT_NAME,
      bankId:        SEPAY_BANK,
    });
  } catch (e) {
    console.error('[SePay Create]', e);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
