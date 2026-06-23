"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { transferJar } from "@/lib/app/child-actions";
import { useLang } from "./LangProvider";

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
  const { t } = useLang();
  const total = spend + save + share;
  const [open, setOpen] = useState(false);
  const [to, setTo] = useState<"save" | "share">("save");
  const [amount, setAmount] = useState(10);
  const [error, setError] = useState("");
  const [pending, start] = useTransition();

  function doTransfer() {
    setError("");
    if (amount <= 0 || amount > spend) {
      setError(t("invalidAmount"));
      return;
    }
    start(async () => {
      const res = await transferJar({ childId, to, amount });
      if (res.ok) {
        setOpen(false);
        router.refresh();
      } else {
        setError(res.error ?? t("transferFailed"));
      }
    });
  }

  return (
    <div>
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Jar emoji="🛒" name={t("jarSpend")} amount={spend} total={total} color="#FF6B6B" />
        <Jar emoji="🏦" name={t("jarSave")} amount={save} total={total} color="#00b251" />
        <Jar emoji="❤️" name={t("jarShare")} amount={share} total={total} color="#f59e0b" />
      </div>

      <div className="gw-card" style={{ marginTop: "16px", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <div>
          <p style={{ fontSize: "13px", color: "var(--ink-soft)", fontWeight: 700 }}>{t("totalCoins")}</p>
          <p style={{ fontSize: "24px", fontWeight: 900, color: "var(--ink)" }}>🪙 {total.toLocaleString("vi-VN")}</p>
        </div>
        <button onClick={() => setOpen(true)} className="gw-btn gw-btn--primary gw-btn--sm">
          <span className="material-symbols-outlined">swap_horiz</span>
          {t("transfer")}
        </button>
      </div>

      {open && (
        <div style={{ position: "fixed", inset: 0, zIndex: 50, display: "flex", alignItems: "center", justifyContent: "center", background: "rgba(0,0,0,.45)", padding: "16px" }}>
          <div className="gw-card" style={{ width: "100%", maxWidth: "360px" }}>
            <h3 style={{ fontSize: "17px", fontWeight: 900, color: "var(--ink)", marginBottom: "16px" }}>{t("transferFromSpend")}</h3>
            <div style={{ display: "flex", gap: "8px", marginBottom: "16px" }}>
              {(["save", "share"] as const).map((k) => (
                <button
                  key={k}
                  onClick={() => setTo(k)}
                  className={`gw-tab${to === k ? " active" : ""}`}
                  style={{ flex: 1 }}
                >
                  {k === "save" ? t("toSave") : t("toShare")}
                </button>
              ))}
            </div>
            <div className="gw-field" style={{ marginBottom: "8px" }}>
              <span className="material-symbols-outlined">toll</span>
              <input
                type="number"
                min={1}
                max={spend}
                value={amount}
                onChange={(e) => setAmount(Number(e.target.value))}
                className="gw-input"
                placeholder="Số xu cần chuyển"
              />
            </div>
            {error && <p style={{ fontSize: "13px", color: "var(--error)", marginBottom: "8px" }}>{error}</p>}
            <div style={{ display: "flex", gap: "8px", marginTop: "8px" }}>
              <button onClick={() => setOpen(false)} className="gw-btn gw-btn--ghost gw-btn--sm" style={{ flex: 1 }}>
                {t("cancel")}
              </button>
              <button onClick={doTransfer} disabled={pending} className="gw-btn gw-btn--primary gw-btn--sm" style={{ flex: 1 }}>
                {pending ? t("transferring") : t("transferBtn")}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function Jar({ emoji, name, amount, total, color }: {
  emoji: string; name: string; amount: number; total: number; color: string;
}) {
  const pct = total > 0 ? Math.round((amount / total) * 100) : 0;
  return (
    <div className="gw-card" style={{ textAlign: "center" }}>
      <div style={{ fontSize: "40px", marginBottom: "8px" }}>{emoji}</div>
      <p style={{ fontWeight: 800, color: "var(--ink)" }}>{name}</p>
      <p style={{ fontSize: "22px", fontWeight: 900, marginTop: "4px", color }}>
        🪙 {amount.toLocaleString("vi-VN")}
      </p>
      <div style={{ height: "10px", borderRadius: "999px", background: "rgba(0,0,0,.07)", marginTop: "12px", overflow: "hidden" }}>
        <div style={{ height: "100%", borderRadius: "999px", width: `${pct}%`, background: color, transition: "width .4s" }} />
      </div>
      <p style={{ fontSize: "12px", color: "var(--ink-soft)", marginTop: "4px", fontWeight: 700 }}>{pct}%</p>
    </div>
  );
}
