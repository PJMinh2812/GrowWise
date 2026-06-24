import { getSelectedChild } from "@/lib/app/children";
import { getTransactions } from "@/lib/app/ledger";
import { getDreamItems } from "@/lib/app/dreams";
import DreamsView from "@/components/app/DreamsView";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

export default async function ThuChiPage() {
  const lang = await getLang();
  const child = await getSelectedChild();
  if (!child) {
    return <div className="gw-card" style={{ padding: "24px", color: "var(--ink-soft)" }}>{t(lang, "childNoProfileShort")}</div>;
  }
  const [txns, dreams] = await Promise.all([
    getTransactions(child.id),
    getDreamItems(child.id),
  ]);
  const fmt = (n: number) => n.toLocaleString("vi-VN");

  return (
    <div className="pt-4">
      <div className="gw-h">
        <h2>{t(lang, "thuChiTitle")} 💰</h2>
      </div>

      {/* Jar balances */}
      <section className="grid grid-cols-3 gap-2 mb-4">
        {[
          { emoji: "🛒", label: t(lang, "jarSpend"), val: child.spend_jar },
          { emoji: "🏦", label: t(lang, "jarSave"), val: child.save_jar },
          { emoji: "❤️", label: t(lang, "jarShare"), val: child.share_jar },
        ].map((j) => (
          <div key={j.label} className="gw-card" style={{ textAlign: "center", padding: "12px 6px" }}>
            <div style={{ fontSize: 22 }}>{j.emoji}</div>
            <div className="font-black text-on-surface" style={{ fontSize: 18 }}>{fmt(j.val)}</div>
            <div className="text-[11px] text-on-surface-variant">{j.label}</div>
          </div>
        ))}
      </section>

      {/* Transaction history */}
      <section className="mb-6">
        <h3 className="font-extrabold text-on-surface mb-2">{t(lang, "thuChiTitle")}</h3>
        {txns.length === 0 ? (
          <div className="gw-card" style={{ padding: "24px", textAlign: "center", color: "var(--ink-soft)" }}>
            {t(lang, "noTransactions")}
          </div>
        ) : (
          <div className="space-y-2">
            {txns.map((tx) => {
              const income = tx.type === "income";
              return (
                <div key={tx.id} className="gw-card" style={{ display: "flex", alignItems: "center", gap: 12, padding: "12px 14px" }}>
                  <span className="grid place-items-center shrink-0" style={{ width: 36, height: 36, borderRadius: 10, background: income ? "var(--color-secondary-container)" : "var(--color-error-container)" }}>
                    {income ? "📥" : "📤"}
                  </span>
                  <div className="flex-1 min-w-0">
                    <p className="font-bold text-on-surface truncate">{tx.note ?? (income ? t(lang, "labelIncome") : t(lang, "labelExpense"))}</p>
                    <p className="text-[11px] text-on-surface-variant">{new Date(tx.created_at).toLocaleDateString(lang === "en" ? "en-US" : "vi-VN")}</p>
                  </div>
                  <span className="font-black" style={{ color: income ? "#1F8A4C" : "#C0392B" }}>
                    {income ? "+" : "−"}{fmt(tx.amount)} 🪙
                  </span>
                </div>
              );
            })}
          </div>
        )}
      </section>

      {/* Savings plan = Dreams */}
      <section>
        <h3 className="font-extrabold text-on-surface mb-2">{t(lang, "savingsPlan")} ⭐</h3>
        <DreamsView childId={child.id} totalCoins={child.total_coins} dreams={dreams} />
      </section>
    </div>
  );
}
