"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";

type Provider = "momo" | "payos";
type Billing = "monthly" | "yearly";

interface CreateResult {
  orderId: string;
  qrCodeUrl?: string | null; // momo
  payUrl?: string | null;
  deeplink?: string | null;
  qrCode?: string | null; // payos EMV string
  checkoutUrl?: string | null;
  accountNumber?: string | null;
  accountName?: string | null;
  amount?: number | null;
  description?: string | null;
}

export default function PaymentQrModal({
  planName,
  billingInterval,
  onClose,
}: {
  planName: "premium" | "family";
  billingInterval: Billing;
  onClose: () => void;
}) {
  const router = useRouter();
  const [provider, setProvider] = useState<Provider>("payos");
  const [data, setData] = useState<CreateResult | null>(null);
  const [status, setStatus] = useState<"creating" | "waiting" | "paid" | "error">("creating");
  const [error, setError] = useState("");
  const [countdown, setCountdown] = useState(900);
  const pollRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const countdownRef = useRef<ReturnType<typeof setInterval> | null>(null);

  useEffect(() => {
    let cancelled = false;
    setStatus("creating");
    setData(null);
    if (pollRef.current) clearInterval(pollRef.current);

    (async () => {
      const supabase = createClient();
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) {
        setError("Bạn cần đăng nhập");
        setStatus("error");
        return;
      }
      const endpoint = provider === "momo" ? "/api/payment/momo/create" : "/api/payment/qr/create";
      const res = await fetch(endpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ userId: user.id, planName, billingInterval }),
      });
      const json = await res.json();
      if (cancelled) return;
      if (!res.ok) {
        setError(json.error ?? "Không tạo được thanh toán");
        setStatus("error");
        return;
      }
      setData(json);
      setStatus("waiting");

      const statusUrl =
        provider === "momo" ? "/api/payment/momo/status" : "/api/payment/qr/status";
      pollRef.current = setInterval(async () => {
        const r = await fetch(`${statusUrl}?orderId=${json.orderId}`);
        const s = await r.json();
        if (s.status === "paid" || s.status === "success" || s.status === "completed") {
          if (pollRef.current) clearInterval(pollRef.current);
          setStatus("paid");
        } else if (s.status === "cancelled" || s.status === "failed") {
          if (pollRef.current) clearInterval(pollRef.current);
          setError("Thanh toán đã huỷ hoặc hết hạn.");
          setStatus("error");
        }
      }, 3000);
    })();

    return () => {
      cancelled = true;
      if (pollRef.current) clearInterval(pollRef.current);
    };
  }, [provider, planName, billingInterval]);

  // 15-minute countdown — starts when QR is displayed
  useEffect(() => {
    if (status !== "waiting") {
      if (countdownRef.current) { clearInterval(countdownRef.current); countdownRef.current = null; }
      return;
    }
    setCountdown(900);
    countdownRef.current = setInterval(() => {
      setCountdown((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);
    return () => { if (countdownRef.current) { clearInterval(countdownRef.current); countdownRef.current = null; } };
  }, [status]);

  // Trigger timeout when countdown reaches 0
  useEffect(() => {
    if (countdown === 0 && status === "waiting") {
      if (pollRef.current) clearInterval(pollRef.current);
      if (countdownRef.current) clearInterval(countdownRef.current);
      setError("QR hết hạn. Vui lòng thử lại.");
      setStatus("error");
    }
  }, [countdown, status]);

  // MoMo returns `qrCodeUrl` as an EMV QR *string* (not an image URL); PayOS
  // returns `qrCode` as an EMV string too. Render whichever we have as an image.
  const qrPayload = provider === "momo" ? data?.qrCodeUrl : data?.qrCode;
  const qrImg = qrPayload
    ? /^https?:\/\//.test(qrPayload)
      ? qrPayload
      : `https://api.qrserver.com/v1/create-qr-code/?size=240x240&data=${encodeURIComponent(qrPayload)}`
    : null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
      <div className="app-card w-full max-w-sm p-6 text-center">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-bold text-on-surface">Thanh toán {planName === "premium" ? "Nâng Cao" : "Gia Đình"}</h3>
          <button onClick={onClose} aria-label="Đóng" className="text-on-surface-variant">
            <span className="material-symbols-outlined">close</span>
          </button>
        </div>

        {/* provider tabs */}
        <div className="flex gap-2 mb-4">
          {(["payos", "momo"] as const).map((p) => (
            <button
              key={p}
              onClick={() => setProvider(p)}
              className={`flex-1 py-2 rounded-[14px] text-sm font-semibold border ${
                provider === p
                  ? "bg-primary text-on-primary border-primary"
                  : "border-outline-variant text-on-surface-variant"
              }`}
            >
              {p === "payos" ? "QR Ngân hàng" : "MoMo"}
            </button>
          ))}
        </div>

        {status === "creating" && (
          <div className="py-10">
            <span className="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin inline-block" />
            <p className="text-on-surface-variant mt-3">Đang tạo mã QR…</p>
          </div>
        )}

        {status === "waiting" && (
          <div>
            {qrImg ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img
                src={qrImg}
                alt="Mã QR thanh toán"
                width={240}
                height={240}
                className="mx-auto rounded-xl bg-white p-2"
              />
            ) : (
              <p className="text-on-surface-variant">Không có mã QR — dùng nút bên dưới.</p>
            )}
            <p className="text-sm text-on-surface-variant mt-3">
              Quét bằng app {provider === "momo" ? "MoMo" : "ngân hàng"} trên điện thoại để thanh toán.
            </p>
            {provider === "payos" && data?.accountNumber && (
              <div className="text-xs text-on-surface-variant mt-2">
                <p>STK: <b>{data.accountNumber}</b> — {data.accountName}</p>
                <p>Nội dung: <b>{data.description}</b></p>
              </div>
            )}
            {(data?.checkoutUrl || data?.payUrl) && (
              <a
                href={(data.checkoutUrl ?? data.payUrl)!}
                target="_blank"
                rel="noreferrer"
                className="inline-block mt-3 text-sm text-primary font-semibold underline"
              >
                Mở trang thanh toán →
              </a>
            )}
            <p className="text-xs text-on-surface-variant mt-3 flex items-center justify-center gap-1">
              <span className="w-3 h-3 border-2 border-primary border-t-transparent rounded-full animate-spin inline-block" />
              Đang chờ thanh toán…
            </p>
            <p className="text-xs text-on-surface-variant mt-1">
              QR hết hạn sau{" "}
              <span className="font-mono font-semibold tabular-nums">
                {String(Math.floor(countdown / 60)).padStart(2, "0")}:{String(countdown % 60).padStart(2, "0")}
              </span>
            </p>
          </div>
        )}

        {status === "paid" && (
          <div className="py-8">
            <div className="text-6xl mb-2">🎉</div>
            <p className="text-xl font-extrabold text-on-surface">Thanh toán thành công!</p>
            <p className="text-sm text-on-surface-variant mt-1">Gói của bạn đã được kích hoạt.</p>
            <button
              onClick={() => router.push("/parent/settings")}
              className="mt-4 w-full py-2.5 rounded-[14px] bg-primary text-on-primary font-bold"
            >
              Xem gói của tôi →
            </button>
          </div>
        )}

        {status === "error" && (
          <div className="py-8">
            <p className="text-error">{error}</p>
            <button
              onClick={() => router.push("/parent/pricing")}
              className="mt-4 px-5 py-2.5 rounded-[14px] bg-primary text-on-primary font-bold"
            >
              Thử lại
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
