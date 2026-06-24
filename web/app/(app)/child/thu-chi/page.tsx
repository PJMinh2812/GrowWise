import { getSelectedChild } from "@/lib/app/children";
import { getTransactions } from "@/lib/app/ledger";
import { getDreamItems } from "@/lib/app/dreams";
import JarsView from "@/components/app/JarsView";
import DreamsView from "@/components/app/DreamsView";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";
import Emoji from "@/components/Emoji";

export const dynamic = "force-dynamic";

export default async function MoneyPage() {
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
        <h2 style={{ display: "inline-flex", alignItems: "center", gap: "8px" }}>{t(lang, "navMoney")} <Emoji name="moneybag" size={24} /></h2>
      </div>

      {/* 3 jars + transfer */}
      <JarsView childId={child.id} spend={child.spend_jar} save={child.save_jar} share={child.share_jar} />

      {/* Income / Spending history */}
      <section className="mt-6 mb-6">
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
                    <Emoji name={income ? "inbox" : "outbox"} size={20} />
                  </span>
                  <div className="flex-1 min-w-0">
                    <p className="font-bold text-on-surface truncate">{tx.note ?? (income ? t(lang, "labelIncome") : t(lang, "labelExpense"))}</p>
                    <p className="text-[11px] text-on-surface-variant">{new Date(tx.created_at).toLocaleDateString(lang === "en" ? "en-US" : "vi-VN")}</p>
                  </div>
                  <span className="font-black" style={{ color: income ? "#1F8A4C" : "#C0392B", display: "inline-flex", alignItems: "center", gap: "4px" }}>
                    {income ? "+" : "−"}{fmt(tx.amount)} <Emoji name="coin" size={16} />
                  </span>
                </div>
              );
            })}
          </div>
        )}
      </section>

      {/* Goals: short-term then long-term */}
      <section className="mb-6">
        <h3 className="font-extrabold text-on-surface mb-2">{t(lang, "goalShortTitle")}</h3>
        <DreamsView childId={child.id} totalCoins={child.total_coins} dreams={dreams} term="short" />
      </section>
      <section>
        <h3 className="font-extrabold text-on-surface mb-2">{t(lang, "goalLongTitle")}</h3>
        <DreamsView childId={child.id} totalCoins={child.total_coins} dreams={dreams} term="long" />
      </section>
    </div>
  );
}
