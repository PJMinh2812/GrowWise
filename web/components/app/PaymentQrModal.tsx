"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";
import { useLang } from "./LangProvider";

type Billing = "monthly" | "yearly";

interface CreateResult {
  orderId: string;
  qrCode?: string | null; // SePay VietQR image URL
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
  const { t } = useLang();
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
        setError(t("needLogin"));
        setStatus("error");
        return;
      }
      const res = await fetch("/api/payment/sepay/create", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ userId: user.id, planName, billingInterval }),
      });
      const json = await res.json();
      if (cancelled) return;
      if (!res.ok) {
        setError(json.error ?? t("createPaymentError"));
        setStatus("error");
        return;
      }
      setData(json);
      setStatus("waiting");

      pollRef.current = setInterval(async () => {
        const r = await fetch(`/api/payment/sepay/status?orderId=${json.orderId}`);
        const s = await r.json();
        if (s.status === "paid" || s.status === "success" || s.status === "completed") {
          if (pollRef.current) clearInterval(pollRef.current);
          setStatus("paid");
        } else if (s.status === "cancelled" || s.status === "failed") {
          if (pollRef.current) clearInterval(pollRef.current);
          setError(t("paymentCancelled"));
          setStatus("error");
        }
      }, 3000);
    })();

    return () => {
      cancelled = true;
      if (pollRef.current) clearInterval(pollRef.current);
    };
  }, [planName, billingInterval]);

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
      setError(t("qrExpired"));
      setStatus("error");
    }
  }, [countdown, status]);

  // SePay returns `qrCode` as a ready-to-render VietQR image URL.
  const qrImg = data?.qrCode ?? null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
      <div className="gw-card" style={{ width: "100%", maxWidth: "384px", padding: "24px", textAlign: "center" }}>
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-bold text-on-surface">{t("payTitle")} {t(planName === "premium" ? "planPremiumName" : "planFamilyName")}</h3>
          <button onClick={onClose} aria-label={t("close")} className="text-on-surface-variant">
            <span className="material-symbols-outlined">close</span>
          </button>
        </div>

        {status === "creating" && (
          <div className="py-10">
            <span className="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin inline-block" />
            <p className="text-on-surface-variant mt-3">{t("creatingQr")}</p>
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
              <p className="text-on-surface-variant">{t("noQrCode")}</p>
            )}
            <p className="text-sm text-on-surface-variant mt-3">
              Quét bằng app ngân hàng trên điện thoại để thanh toán.
            </p>
            {data?.accountNumber && (
              <div className="text-xs text-on-surface-variant mt-2">
                <p>STK: <b>{data.accountNumber}</b>{data.accountName ? ` — ${data.accountName}` : ""}</p>
                <p>Số tiền: <b>{data.amount?.toLocaleString("vi-VN")}₫</b></p>
                <p>Nội dung: <b>{data.description}</b></p>
              </div>
            )}
            <p className="text-xs text-on-surface-variant mt-3 flex items-center justify-center gap-1">
              <span className="w-3 h-3 border-2 border-primary border-t-transparent rounded-full animate-spin inline-block" />
              {t("waitingPayment")}
            </p>
            <p className="text-xs text-on-surface-variant mt-1">
              {t("qrExpiresIn")}{" "}
              <span className="font-mono font-semibold tabular-nums">
                {String(Math.floor(countdown / 60)).padStart(2, "0")}:{String(countdown % 60).padStart(2, "0")}
              </span>
            </p>
          </div>
        )}

        {status === "paid" && (
          <div className="py-8">
            <div className="text-6xl mb-2">🎉</div>
            <p className="text-xl font-extrabold text-on-surface">{t("paymentSuccess")}</p>
            <p className="text-sm text-on-surface-variant mt-1">{t("planActivated")}</p>
            <button
              onClick={() => router.push("/parent/settings")}
              className="gw-btn gw-btn--primary"
              style={{ marginTop: "16px", width: "100%" }}
            >
              {t("viewMyPlan")}
            </button>
          </div>
        )}

        {status === "error" && (
          <div className="py-8">
            <p className="text-error">{error}</p>
            <button
              onClick={() => router.push("/parent/pricing")}
              className="gw-btn gw-btn--primary"
              style={{ marginTop: "16px" }}
            >
              {t("retry")}
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
