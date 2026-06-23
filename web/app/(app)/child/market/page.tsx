import Link from "next/link";
import { getSelectedChild, getFamilyForUser } from "@/lib/app/children";
import { getTaskTemplates } from "@/lib/app/tasks";
import type { Task } from "@/lib/types";
import { getLang } from "@/lib/i18n-server";
import { t, taskCategoryLabel } from "@/lib/i18n";

export const dynamic = "force-dynamic";

export default async function MarketPage() {
  const lang = await getLang();
  const child = await getSelectedChild();
  const family = await getFamilyForUser();
  const templates = child && family ? await getTaskTemplates(family.id, child.id) : [];

  const byCategory = templates.reduce<Record<string, Task[]>>((acc, task) => {
    (acc[task.category] ??= []).push(task);
    return acc;
  }, {});

  return (
    <div>
      <div className="gw-h">
        <h2>{t(lang, "marketTitle")}</h2>
      </div>

      {templates.length === 0 ? (
        <div className="gw-card" style={{ padding: "32px", textAlign: "center", color: "var(--ink-soft)" }}>
          {t(lang, "marketEmpty")}
        </div>
      ) : (
        <div style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
          {Object.entries(byCategory).map(([cat, tasks]) => (
            <section key={cat}>
              <p style={{ fontWeight: 800, color: "var(--ink)", marginBottom: "10px", fontSize: "15px" }}>{taskCategoryLabel(lang, cat)}</p>
              <div className="gw-grid">
                {tasks.map((task) => (
                  <div key={task.id} className="gw-card">
                    <div style={{ fontSize: "30px", marginBottom: "8px" }}>{task.icon}</div>
                    <p style={{ fontWeight: 800, color: "var(--ink)", fontSize: "14px" }}>{task.title}</p>
                    <p style={{ fontSize: "13px", color: "var(--secondary)", fontWeight: 700, margin: "4px 0 12px" }}>🪙 +{task.coin_reward}</p>
                    <Link href="/child">
                      <button className="gw-btn gw-btn--secondary gw-btn--sm" style={{ width: "100%" }}>{t(lang, "doNow")}</button>
                    </Link>
                  </div>
                ))}
              </div>
            </section>
          ))}
        </div>
      )}
    </div>
  );
}
