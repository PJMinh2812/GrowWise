import { getSelectedChild } from "@/lib/app/children";
import JarsView from "@/components/app/JarsView";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

export default async function JarsPage() {
  const lang = await getLang();
  const child = await getSelectedChild();
  if (!child) {
    return <div className="gw-card" style={{ padding: "24px", color: "var(--ink-soft)" }}>{t(lang, "childNoProfileShort")}</div>;
  }
  return (
    <div>
      <div className="gw-h">
        <h2>{t(lang, "jarsTitle")}</h2>
      </div>
      <JarsView
        childId={child.id}
        spend={child.spend_jar}
        save={child.save_jar}
        share={child.share_jar}
      />
    </div>
  );
}
