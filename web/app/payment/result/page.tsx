import Link from 'next/link';
import { createClient } from '@supabase/supabase-js';

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

  // Mark cancelled in DB when user arrives here with a failed/cancelled resultCode
  if (!success && orderId) {
    await cancelTransactionIfNeeded(orderId);
  }

  return (
    <div className="min-h-screen bg-[#FFF8F3] flex items-center justify-center p-4">
      <div className="bg-white rounded-3xl p-8 max-w-sm w-full text-center shadow-xl border border-[#EEDDCC]">
        <div className="text-7xl mb-4">{success ? '🎉' : '❌'}</div>

        <h1 className="text-2xl font-extrabold text-[#211B10] mb-2">
          {success ? 'Thanh toán thành công!' : 'Giao dịch thất bại'}
        </h1>

        <p className="text-[#564334] text-sm mb-6 leading-relaxed">
          {success
            ? 'Gói của bạn đã được kích hoạt. Bạn có thể xem chi tiết trong phần cài đặt.'
            : (message ?? 'Giao dịch bị huỷ hoặc thất bại. Vui lòng thử lại.')}
        </p>

        {orderId && (
          <div className="bg-[#FFF8F3] rounded-xl px-4 py-2 mb-6 text-xs text-[#897362]">
            Mã đơn: <span className="font-mono font-semibold">{orderId}</span>
          </div>
        )}

        {success ? (
          <Link
            href="/parent/settings"
            className="block w-full py-3 rounded-2xl bg-[#630ED4] text-white font-extrabold text-base hover:opacity-90 transition-opacity"
          >
            Về Dashboard →
          </Link>
        ) : (
          <div className="space-y-3">
            <Link
              href="/parent/pricing"
              className="block w-full py-3 rounded-2xl bg-[#630ED4] text-white font-extrabold text-base hover:opacity-90 transition-opacity"
            >
              Thử lại
            </Link>
            <Link
              href="/parent"
              className="block w-full py-3 rounded-2xl bg-[#FFF8F3] text-[#564334] font-semibold text-sm border border-[#EEDDCC] hover:bg-[#FFF0E0] transition-colors"
            >
              Về Dashboard
            </Link>
          </div>
        )}
      </div>
    </div>
  );
}
