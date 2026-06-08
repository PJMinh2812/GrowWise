import { NextResponse } from 'next/server';
import crypto from 'crypto';
import { createClient } from '@supabase/supabase-js';

const PARTNER_CODE = process.env.MOMO_PARTNER_CODE ?? 'MOMOBKUN20180529';
const ACCESS_KEY   = process.env.MOMO_ACCESS_KEY   ?? 'klm05TvNBzhg7h7j';
const SECRET_KEY   = process.env.MOMO_SECRET_KEY   ?? 'at67qH6mk8w5Y1nAyMoYKMWACiEi2bsa';
const ENDPOINT     = process.env.MOMO_ENDPOINT     ?? 'https://test-payment.momo.vn/v2/gateway/api/create';
const APP_URL      = process.env.NEXT_PUBLIC_APP_URL ?? 'http://localhost:3000';

export async function POST(request: Request) {
  try {
    const { userId, planName, billingInterval } = await request.json();

    if (!userId || !planName || !billingInterval) {
      return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
    }

    const supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!
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
        ? (plan.price_yearly ?? plan.price_monthly)
        : plan.price_monthly;

    const orderId      = `GW${Date.now()}`;
    const requestId    = orderId;
    const orderInfo    = `GrowWise - Gói ${plan.display_name} (${billingInterval === 'yearly' ? 'Năm' : 'Tháng'})`;
    const redirectUrl  = `${APP_URL}/payment/result?orderId=${orderId}`;
    const ipnUrl       = `${APP_URL}/api/payment/momo/ipn`;
    const extraData    = Buffer.from(
      JSON.stringify({ userId, planId: plan.id, planName, billingInterval })
    ).toString('base64');
    const requestType  = 'captureWallet';

    const rawSignature = [
      `accessKey=${ACCESS_KEY}`,
      `amount=${amount}`,
      `extraData=${extraData}`,
      `ipnUrl=${ipnUrl}`,
      `orderId=${orderId}`,
      `orderInfo=${orderInfo}`,
      `partnerCode=${PARTNER_CODE}`,
      `redirectUrl=${redirectUrl}`,
      `requestId=${requestId}`,
      `requestType=${requestType}`,
    ].join('&');

    const signature = crypto
      .createHmac('sha256', SECRET_KEY)
      .update(rawSignature)
      .digest('hex');

    const momoBody = {
      partnerCode: PARTNER_CODE,
      partnerName: 'GrowWise',
      storeId: PARTNER_CODE,
      requestId,
      amount,
      orderId,
      orderInfo,
      redirectUrl,
      ipnUrl,
      lang: 'vi',
      extraData,
      requestType,
      signature,
    };

    const momoRes  = await fetch(ENDPOINT, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(momoBody),
    });
    const momoData = await momoRes.json();

    await supabase.from('payment_transactions').insert({
      order_id:        orderId,
      user_id:         userId,
      plan_name:       planName,
      billing_interval: billingInterval,
      amount,
      status:          'pending',
      provider:        'momo',
    });

    return NextResponse.json({
      orderId,
      payUrl:     momoData.payUrl      ?? null,
      deeplink:   momoData.deeplink    ?? momoData.deeplinkWebInApp ?? null,
      qrCodeUrl:  momoData.qrCodeUrl   ?? null,
      resultCode: momoData.resultCode  ?? -1,
      message:    momoData.message     ?? '',
    });
  } catch (e) {
    console.error('[MoMo Create]', e);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
