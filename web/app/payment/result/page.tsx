import Link from 'next/link';
import { createClient } from '@supabase/supabase-js';
import { activateSubscriptionForOrder } from '@/lib/payment/subscription';
import Emoji from '@/components/Emoji';

export const metadata = {
  title: 'Kết quả thanh toán – GrowWise',
};

interface Props {
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>;
}

function getFirst(v: string | string[] | undefined): string | undefined {
  if (Array.isArray(v)) return v[0];
  return v;
}

async function cancelTransactionIfNeeded(orderId: string) {
  try {
    const supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!,
    );
    await supabase
      .from('payment_transactions')
      .update({ status: 'cancelled', updated_at: new Date().toISOString() })
      .eq('order_id', orderId)
      .eq('status', 'pending');
  } catch {
    // non-fatal — IPN may have already updated it
  }
}

export default async function PaymentResultPage({ searchParams }: Props) {
  const params = await searchParams;
  const orderId = getFirst(params.orderId);
  const resultCode = getFirst(params.resultCode);
  const message = getFirst(params.message);

  const success = resultCode === '0';

  if (orderId) {
    if (success) {
      await activateSubscriptionForOrder(orderId);
    } else {
      await cancelTransactionIfNeeded(orderId);
    }
  }

  return (
    <div style={{ minHeight: '100vh', background: 'var(--cream)', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '16px' }}>
      <div className={`gw-card ${success ? 'gw-card--glow' : ''}`} style={{ maxWidth: '384px', width: '100%', textAlign: 'center' }}>
        <div style={{ fontSize: '72px', marginBottom: '16px' }}>{success ? <Emoji name="party" size={72} /> : '❌'}</div>

        <h1 style={{ fontSize: '24px', fontWeight: 900, color: 'var(--ink)', marginBottom: '8px' }}>
          {success ? 'Thanh toán thành công!' : 'Giao dịch thất bại'}
        </h1>

        <p style={{ color: 'var(--ink-soft)', fontSize: '14px', marginBottom: '24px', lineHeight: 1.6 }}>
          {success
            ? 'Gói của bạn đã được kích hoạt. Bạn có thể xem chi tiết trong phần cài đặt.'
            : (message ?? 'Giao dịch bị huỷ hoặc thất bại. Vui lòng thử lại.')}
        </p>

        {orderId && (
          <div style={{ background: 'var(--primary-fixed)', borderRadius: '12px', padding: '8px 16px', marginBottom: '24px', fontSize: '12px', color: 'var(--ink-soft)' }}>
            Mã đơn: <span style={{ fontFamily: 'monospace', fontWeight: 700 }}>{orderId}</span>
          </div>
        )}

        {success ? (
          <Link
            href="/parent/settings"
            className="gw-btn gw-btn--primary"
            style={{ display: 'block', width: '100%' }}
          >
            Về Dashboard →
          </Link>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <Link
              href="/parent/pricing"
              className="gw-btn gw-btn--primary"
              style={{ display: 'block', width: '100%' }}
            >
              Thử lại
            </Link>
            <Link
              href="/parent"
              className="gw-btn gw-btn--ghost"
              style={{ display: 'block', width: '100%' }}
            >
              Về Dashboard
            </Link>
          </div>
        )}
      </div>
    </div>
  );
}
