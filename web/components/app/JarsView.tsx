"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { transferJar } from "@/lib/app/child-actions";

export default function JarsView({
  childId,
  spend,
  save,
  share,
}: {
  childId: string;
  spend: number;
  save: number;
  share: number;
}) {
  const router = useRouter();
  const total = spend + save + share;
  const [open, setOpen] = useState(false);
  const [to, setTo] = useState<"save" | "share">("save");
  const [amount, setAmount] = useState(10);
  const [error, setError] = useState("");
  const [pending, start] = useTransition();

  function doTransfer() {
    setError("");
    if (amount <= 0 || amount > spend) {
      setError("Số xu không hợp lệ (vượt quá hũ Tiêu).");
      return;
    }
    start(async () => {
      const res = await transferJar({ childId, to, amount });
      if (res.ok) {
        setOpen(false);
        router.refresh();
      } else {
        setError(res.error ?? "Chuyển thất bại");
      }
    });
  }

  return (
    <div>
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Jar emoji="🛒" name="Hũ Tiêu" amount={spend} total={total} color="#FF6B6B" />
        <Jar emoji="🏦" name="Hũ Tiết kiệm" amount={save} total={total} color="#00b251" />
        <Jar emoji="❤️" name="Hũ Chia sẻ" amount={share} total={total} color="#f59e0b" />
      </div>

      <div className="mt-6 flex items-center justify-between app-card p-5">
        <div>
          <p className="text-sm text-on-surface-variant">Tổng số xu</p>
          <p className="text-2xl font-extrabold text-on-surface">🪙 {total.toLocaleString("vi-VN")}</p>
        </div>
        <button
          onClick={() => setOpen(true)}
          className="px-5 py-2.5 rounded-[14px] bg-primary text-on-primary font-bold"
        >
          Chuyển xu
        </button>
      </div>

      {open && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
          <div className="app-card w-full max-w-sm p-6">
            <h3 className="text-lg font-bold text-on-surface mb-4">Chuyển xu từ hũ Tiêu</h3>
            <div className="flex gap-2 mb-4">
              {(["save", "share"] as const).map((k) => (
                <button
                  key={k}
                  onClick={() => setTo(k)}
                  className={`flex-1 py-2 rounded-[14px] text-sm font-semibold border ${
                    to === k
                      ? "bg-primary text-on-primary border-primary"
                      : "border-outline-variant text-on-surface-variant"
                  }`}
                >
                  {k === "save" ? "→ Tiết kiệm" : "→ Chia sẻ"}
                </button>
              ))}
            </div>
            <input
              type="number"
              min={1}
              max={spend}
              value={amount}
              onChange={(e) => setAmount(Number(e.target.value))}
              className="w-full border border-outline-variant rounded-[14px] px-3 py-2.5 text-on-surface mb-2"
            />
            {error && <p className="text-sm text-error mb-2">{error}</p>}
            <div className="flex gap-2 mt-2">
              <button
                onClick={() => setOpen(false)}
                className="flex-1 py-2.5 rounded-[14px] bg-surface-container text-on-surface-variant font-semibold"
              >
                Huỷ
              </button>
              <button
                onClick={doTransfer}
                disabled={pending}
                className="flex-1 py-2.5 rounded-[14px] bg-primary text-on-primary font-bold disabled:opacity-50"
              >
                {pending ? "Đang chuyển…" : "Chuyển"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function Jar({
  emoji,
  name,
  amount,
  total,
  color,
}: {
  emoji: string;
  name: string;
  amount: number;
  total: number;
  color: string;
}) {
  const pct = total > 0 ? Math.round((amount / total) * 100) : 0;
  return (
    <div className="app-card p-5 text-center">
      <div className="text-4xl mb-2">{emoji}</div>
      <p className="font-bold text-on-surface">{name}</p>
      <p className="text-2xl font-extrabold mt-1" style={{ color }}>
        🪙 {amount.toLocaleString("vi-VN")}
      </p>
      <div className="h-2.5 rounded-full bg-surface-container-highest mt-3 overflow-hidden">
        <div className="h-full rounded-full" style={{ width: `${pct}%`, backgroundColor: color }} />
      </div>
      <p className="text-xs text-on-surface-variant mt-1">{pct}%</p>
    </div>
  );
}
