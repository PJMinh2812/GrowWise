import { NextResponse } from 'next/server';
import { PayOS } from '@payos/node';
import { createClient } from '@supabase/supabase-js';

const APP_URL = process.env.NEXT_PUBLIC_APP_URL ?? 'http://localhost:3000';

export async function POST(request: Request) {
  // Instantiate inside handler so missing env vars don't fail at build time
  const payos = new PayOS();
  try {
    const { userId, planName, billingInterval } = await request.json();

    if (!userId || !planName || !billingInterval) {
      return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
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
        ? (plan.price_yearly ?? plan.price_monthly)
        : plan.price_monthly;

    // PayOS orderCode must be a unique number (max 9007199254740991)
    const orderCode = Number(String(Date.now()).slice(-9));
    const orderId   = `GWQ${orderCode}`;

    // Bank transfer description: max 25 chars, alphanumeric only
    const shortId   = userId.replace(/-/g, '').slice(0, 6).toUpperCase();
    const description = `GW${shortId}`;

    const payosOrder = await payos.paymentRequests.create({
      orderCode,
      amount,
      description,
      items: [
        {
          name: `GrowWise ${plan.display_name} (${billingInterval === 'yearly' ? 'Nam' : 'Thang'})`,
          quantity: 1,
          price: amount,
        },
      ],
      returnUrl:  `${APP_URL}/payment/result?orderId=${orderId}`,
      cancelUrl:  `${APP_URL}/payment/cancel?orderId=${orderId}`,
    });

    await supabase.from('payment_transactions').insert({
      order_id:                orderId,
      user_id:                 userId,
      plan_name:               planName,
      billing_interval:        billingInterval,
      amount,
      status:                  'pending',
      provider:                'payos',
      provider_transaction_id: String(orderCode),
    });

    return NextResponse.json({
      orderId,
      orderCode,
      qrCode:        payosOrder.qrCode,
      checkoutUrl:   payosOrder.checkoutUrl,
      amount:        payosOrder.amount,
      description:   payosOrder.description,
      accountNumber: payosOrder.accountNumber,
      accountName:   payosOrder.accountName,
      bankId:        payosOrder.bin,
    });
  } catch (e) {
    console.error('[PayOS QR Create]', e);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
