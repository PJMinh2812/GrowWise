import { NextResponse } from 'next/server';
import crypto from 'crypto';
import { createClient } from '@supabase/supabase-js';
import { activateSubscriptionForOrder } from '@/lib/payment/momo-verify';

const ACCESS_KEY = process.env.MOMO_ACCESS_KEY ?? 'klm05TvNBzhg7h7j';
const SECRET_KEY = process.env.MOMO_SECRET_KEY ?? 'at67qH6mk8w5Y1nAyMoYKMWACiEi2bsa';

export async function POST(request: Request) {
  try {
    const data = await request.json();
    const {
      partnerCode, orderId, requestId, amount, orderInfo,
      orderType, transId, resultCode, message, payType,
      responseTime, extraData, signature,
    } = data;

    // Verify HMAC-SHA256 signature from MoMo
    const rawSignature = [
      `accessKey=${ACCESS_KEY}`,
      `amount=${amount}`,
      `extraData=${extraData}`,
      `message=${message}`,
      `orderId=${orderId}`,
      `orderInfo=${orderInfo}`,
      `orderType=${orderType}`,
      `partnerCode=${partnerCode}`,
      `payType=${payType}`,
      `requestId=${requestId}`,
      `responseTime=${responseTime}`,
      `resultCode=${resultCode}`,
      `transId=${transId}`,
    ].join('&');

    const expected = crypto
      .createHmac('sha256', SECRET_KEY)
      .update(rawSignature)
      .digest('hex');

    if (signature !== expected) {
      return NextResponse.json({ message: 'Invalid signature' }, { status: 400 });
    }

    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
    const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
    if (!supabaseUrl || !serviceKey) {
      console.error('[MoMo IPN] Missing Supabase env vars');
      return NextResponse.json({ message: 'OK' }); // still 200 so MoMo won't retry
    }

    const supabase = createClient(supabaseUrl, serviceKey);

    const status = Number(resultCode) === 0 ? 'completed' : 'failed';

    const { error: txErr } = await supabase
      .from('payment_transactions')
      .update({
        status,
        provider_transaction_id: String(transId),
        updated_at: new Date().toISOString(),
      })
      .eq('order_id', orderId);

    if (txErr) {
      console.error('[MoMo IPN] Failed to update payment_transactions:', txErr);
    }

    if (Number(resultCode) === 0) {
      const ok = await activateSubscriptionForOrder(orderId);
      if (!ok) {
        console.error('[MoMo IPN] Failed to activate subscription for order:', orderId);
      } else {
        console.log('[MoMo IPN] Subscription activated for order:', orderId);
      }
    }

    return NextResponse.json({ message: 'OK' });
  } catch (e) {
    console.error('[MoMo IPN]', e);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
