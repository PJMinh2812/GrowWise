import { getSelectedChild } from "@/lib/app/children";
import { getDreamItems } from "@/lib/app/dreams";
import DreamsView from "@/components/app/DreamsView";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

export default async function DreamsPage() {
  const lang = await getLang();
  const child = await getSelectedChild();
  if (!child) return <div className="gw-card" style={{ padding: "24px", color: "var(--ink-soft)" }}>{t(lang, "childNoProfileShort")}</div>;
  const dreams = await getDreamItems(child.id);
  return (
    <div>
      <div className="gw-h">
        <h2>{t(lang, "dreamsTitle")}</h2>
      </div>
      <DreamsView childId={child.id} totalCoins={child.total_coins} dreams={dreams} />
    </div>
  );
}
