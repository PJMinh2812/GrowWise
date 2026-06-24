"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { useLang } from "./LangProvider";
import { useToast } from "./ToastProvider";
import { deductCoins } from "@/lib/app/parent-actions";
import Emoji from "@/components/Emoji";

export interface ChildFinance {
  id: string;
  name: string;
  emoji: string;
  total: number;
  spend: number;
  save: number;
  share: number;
}

export default function ParentFinanceCard({ children }: { children: ChildFinance[] }) {
  const { t } = useLang();
  const { toast } = useToast();
  const router = useRouter();
  const [pending, start] = useTransition();
  const [deductFor, setDeductFor] = useState<string | null>(null);
  const [amount, setAmount] = useState("");
  const [note, setNote] = useState("");

  if (children.length === 0) return null;
  const fmt = (n: number) => n.toLocaleString("vi-VN");

  function submitDeduct(childId: string) {
    const amt = parseInt(amount);
    if (!amt || amt <= 0) { toast(t("toastError"), "error"); return; }
    start(async () => {
      const res = await deductCoins({ childId, amount: amt, note });
      if (res.ok) {
        toast(t("deductBtn") + " ✓", "success");
        setDeductFor(null); setAmount(""); setNote("");
        router.refresh();
      } else {
        toast(res.error ?? t("toastError"), "error");
      }
    });
  }

  return (
    <div className="mb-4">
      <h2 className="font-extrabold text-on-surface mb-2">{t("childFinanceTitle")}</h2>
      <div className="space-y-3">
        {children.map((c) => (
          <div key={c.id} className="gw-card" style={{ padding: "14px 16px" }}>
            <div className="flex items-center gap-3 mb-2">
              <span style={{ fontSize: 24 }}>{c.emoji}</span>
              <span className="font-extrabold text-on-surface flex-1">{c.name}</span>
              <span className="font-black text-primary" style={{ display: "inline-flex", alignItems: "center", gap: "4px" }}>{fmt(c.total)} <Emoji name="coin" size={18} /></span>
            </div>
            <div className="grid grid-cols-3 gap-2 text-center">
              {[
                { label: t("jarSpend"), val: c.spend },
                { label: t("jarSave"), val: c.save },
                { label: t("jarShare"), val: c.share },
              ].map((j) => (
                <div key={j.label} style={{ background: "var(--color-surface-container)", borderRadius: 10, padding: "6px 4px" }}>
                  <div className="font-extrabold text-on-surface text-sm">{fmt(j.val)}</div>
                  <div className="text-[10px] text-on-surface-variant">{j.label}</div>
                </div>
              ))}
            </div>
            <button
              disabled={pending}
              onClick={() => setDeductFor(deductFor === c.id ? null : c.id)}
              className="gw-btn gw-btn--ghost gw-btn--sm mt-3"
              style={{ width: "auto" }}
            >
              ➖ {t("deductTitle")}
            </button>
            {deductFor === c.id && (
              <div className="mt-2 flex flex-col gap-2">
                <input type="number" min={1} value={amount} onChange={(e) => setAmount(e.target.value)} placeholder="Xu" className="gw-input" style={{ paddingLeft: 16 }} />
                <input value={note} onChange={(e) => setNote(e.target.value)} placeholder={t("deductReasonPh")} className="gw-input" style={{ paddingLeft: 16 }} />
                <button disabled={pending} onClick={() => submitDeduct(c.id)} className="gw-btn gw-btn--danger gw-btn--sm">
                  {t("deductBtn")}
                </button>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
