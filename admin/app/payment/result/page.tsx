export const metadata = {
  title: 'Kết quả thanh toán – GrowWise',
};

interface Props {
  searchParams: Promise<{ orderId?: string; resultCode?: string; message?: string }>;
}

export default async function PaymentResultPage({ searchParams }: Props) {
  const params = await searchParams;
  const success = params.resultCode === '0' || params.resultCode === undefined;

  return (
    <div className="min-h-screen bg-[#FFF8F3] flex items-center justify-center p-4">
      <div className="bg-white rounded-3xl p-8 max-w-sm w-full text-center shadow-xl border border-[#EEDDCC]">
        <div className="text-7xl mb-4">{success ? '🎉' : '❌'}</div>

        <h1 className="text-2xl font-extrabold text-[#211B10] mb-2">
          {success ? 'Thanh toán thành công!' : 'Thanh toán thất bại'}
        </h1>

        <p className="text-[#564334] text-sm mb-6 leading-relaxed">
          {success
            ? 'Gói Premium đã được kích hoạt. Quay lại ứng dụng GrowWise để bắt đầu trải nghiệm!'
            : (params.message ?? 'Đã xảy ra lỗi trong quá trình thanh toán. Vui lòng thử lại.')}
        </p>

        {params.orderId && (
          <div className="bg-[#FFF8F3] rounded-xl px-4 py-2 mb-6 text-xs text-[#897362]">
            Mã đơn: <span className="font-mono font-semibold">{params.orderId}</span>
          </div>
        )}

        <div className="flex items-center justify-center gap-2 text-sm text-[#564334] bg-[#FFF8F3] rounded-2xl px-5 py-3">
          <span className="text-xl">📱</span>
          <span>
            Mở lại ứng dụng <strong>GrowWise</strong> để tiếp tục
          </span>
        </div>

        {success && (
          <p className="mt-6 text-xs text-[#B39882]">
            Subscription được kích hoạt tự động — không cần làm gì thêm.
          </p>
        )}
      </div>
    </div>
  );
}
