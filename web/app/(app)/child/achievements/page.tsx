import { getSelectedChild } from "@/lib/app/children";
import { getBadges } from "@/lib/app/dreams";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

export default async function AchievementsPage() {
  const lang = await getLang();
  const child = await getSelectedChild();
  if (!child) return <div className="gw-card" style={{ padding: "24px", color: "var(--ink-soft)" }}>{t(lang, "childNoProfileShort")}</div>;
  const badges = await getBadges(child.id);

  return (
    <div>
      <div className="gw-h">
        <h2>{t(lang, "achievementsTitle")}</h2>
      </div>

      <div className="gw-card" style={{ marginBottom: "20px", display: "flex", alignItems: "center", gap: "16px" }}>
        <span style={{ fontSize: "40px" }}>{child.avatar_emoji}</span>
        <div>
          <p style={{ fontWeight: 800, color: "var(--ink)" }}>{t(lang, "childLevel")} {child.level}</p>
          <p style={{ fontSize: "13px", color: "var(--ink-soft)" }}>{badges.length} {t(lang, "badgesEarned")}</p>
        </div>
      </div>

      {badges.length === 0 ? (
        <div className="gw-card" style={{ padding: "32px", textAlign: "center", color: "var(--ink-soft)" }}>
          {t(lang, "noBadges")}
        </div>
      ) : (
        <div className="gw-grid">
          {badges.map((b) => (
            <div key={b.id} className="gw-card" style={{ textAlign: "center" }}>
              <div style={{ fontSize: "36px", marginBottom: "8px" }}>{b.emoji}</div>
              <p style={{ fontWeight: 800, color: "var(--ink)", fontSize: "14px" }}>{b.title}</p>
              <p style={{ fontSize: "12px", color: "var(--ink-soft)", marginTop: "4px" }}>
                {new Date(b.earned_at).toLocaleDateString(lang === "en" ? "en-US" : "vi-VN")}
              </p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
