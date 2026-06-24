"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { useLang } from "./LangProvider";
import { useToast } from "./ToastProvider";
import { seedRoadmapForChild } from "@/lib/app/roadmap";
import { deductCoins } from "@/lib/app/parent-actions";

interface ChildLite {
  id: string;
  name: string;
  emoji: string;
}

export default function ParentChildTools({ children }: { children: ChildLite[] }) {
  const { t } = useLang();
  const { toast } = useToast();
  const router = useRouter();
  const [pending, start] = useTransition();
  const [deductFor, setDeductFor] = useState<string | null>(null);
  const [amount, setAmount] = useState("");
  const [note, setNote] = useState("");

  if (children.length === 0) return null;

  function roadmap(childId: string) {
    start(async () => {
      const res = await seedRoadmapForChild(childId);
      if (res.ok) toast(res.seeded ? `${t("createRoadmap")} ✓ (${res.seeded})` : t("roadmapRunning"), "success");
      else toast(res.error ?? t("toastError"), "error");
      router.refresh();
    });
  }

  function submitDeduct(childId: string) {
    const amt = parseInt(amount);
    if (!amt || amt <= 0) {
      toast(t("toastError"), "error");
      return;
    }
    start(async () => {
      const res = await deductCoins({ childId, amount: amt, note });
      if (res.ok) {
        toast(t("deductBtn") + " ✓", "success");
        setDeductFor(null);
        setAmount("");
        setNote("");
        router.refresh();
      } else {
        toast(res.error ?? t("toastError"), "error");
      }
    });
  }

  return (
    <div className="mt-8">
      <h2 className="font-extrabold text-on-surface mb-3">{t("roadmapRunning")}</h2>
      <div className="space-y-3">
        {children.map((c) => (
          <div key={c.id} className="gw-card" style={{ padding: "14px 16px" }}>
            <div className="flex items-center gap-3">
              <span style={{ fontSize: 26 }}>{c.emoji}</span>
              <span className="font-extrabold text-on-surface flex-1">{c.name}</span>
              <button
                disabled={pending}
                onClick={() => roadmap(c.id)}
                className="gw-btn gw-btn--ghost gw-btn--sm"
                style={{ width: "auto" }}
              >
                🧭 {t("createRoadmap")}
              </button>
              <button
                disabled={pending}
                onClick={() => setDeductFor(deductFor === c.id ? null : c.id)}
                className="gw-btn gw-btn--ghost gw-btn--sm"
                style={{ width: "auto" }}
              >
                ➖ {t("deductTitle")}
              </button>
            </div>
            {deductFor === c.id && (
              <div className="mt-3 flex flex-col gap-2">
                <input
                  type="number"
                  min={1}
                  value={amount}
                  onChange={(e) => setAmount(e.target.value)}
                  placeholder="Xu"
                  className="gw-input"
                  style={{ paddingLeft: 16 }}
                />
                <input
                  value={note}
                  onChange={(e) => setNote(e.target.value)}
                  placeholder={t("deductReasonPh")}
                  className="gw-input"
                  style={{ paddingLeft: 16 }}
                />
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
