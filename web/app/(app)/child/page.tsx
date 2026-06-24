import Link from "next/link";
import { getSelectedChild } from "@/lib/app/children";
import { getChildSubmissions } from "@/lib/app/submissions";
import { getBadges } from "@/lib/app/dreams";
import SurveyBanner from "@/components/app/SurveyBanner";
import { getActiveSurveyFor } from "@/lib/app/surveys";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";
import Icon from "@/components/Icon";
import Emoji from "@/components/Emoji";

export const dynamic = "force-dynamic";

export default async function ChildHome() {
  const lang = await getLang();
  const child = await getSelectedChild();

  if (!child) {
    return (
      <div className="gw-card mt-4 text-center">
        <p className="text-on-surface font-semibold">{t(lang, "childNoProfile")}</p>
        <Link href="/role" className="inline-block mt-4 text-primary font-extrabold underline">
          {t(lang, "backToRole")}
        </Link>
      </div>
    );
  }

  const [submissions, badges] = await Promise.all([
    getChildSubmissions(child.id),
    getBadges(child.id),
  ]);

  // Streak = consecutive days (ending today/yesterday) with an approved task.
  const dayKey = (iso: string) => new Date(iso).toISOString().slice(0, 10);
  const doneDays = new Set(
    submissions
      .filter((s) => s.status === "approved")
      .map((s) => dayKey(s.reviewed_at ?? s.submitted_at ?? s.created_at)),
  );
  let streak = 0;
  {
    const cursor = new Date();
    if (!doneDays.has(cursor.toISOString().slice(0, 10))) cursor.setDate(cursor.getDate() - 1);
    while (doneDays.has(cursor.toISOString().slice(0, 10))) {
      streak += 1;
      cursor.setDate(cursor.getDate() - 1);
    }
  }

  // Coins waiting to be collected into a jar.
  const pendingCoins = submissions
    .filter((s) => s.status === "approved" && !s.collected)
    .reduce((sum, s) => sum + (s.coin_earned ?? 0), 0);

  const xpPct = Math.min(100, Math.round((child.xp / Math.max(1, child.xp_to_next_level)) * 100));
  const survey = await getActiveSurveyFor("child", { id: child.id, age: child.age });

  return (
    <div className="pt-4">
      {/* Greeting */}
      <div className="flex items-center gap-3 mb-4 rise">
        <span className="gw-avatar text-2xl">{child.avatar_emoji}</span>
        <div className="min-w-0">
          <h1 className="text-xl font-black text-primary truncate">
            {lang === "en" ? `Hi ${child.name}!` : `Chào bé ${child.name}!`}
          </h1>
          <p className="text-sm font-bold text-on-surface-variant">{t(lang, "hiDoTasks")}</p>
        </div>
      </div>

      {/* Bento: level (XP) + coins */}
      <section className="grid grid-cols-2 gap-3 mb-4">
        <div className="gw-card gw-card--glow gw-card--press rise" style={{ minHeight: 128 }}>
          <div className="flex items-start justify-between">
            <span className="font-extrabold text-on-surface-variant text-sm">{t(lang, "childLevel")}</span>
            <span className="grid place-items-center w-9 h-9 rounded-full bg-secondary-container text-secondary">
              <Icon name="star" className="text-xl" />
            </span>
          </div>
          <div className="mt-4">
            <div className="flex justify-between items-end mb-1.5">
              <span className="text-xl font-black text-on-surface">Level {child.level}</span>
              <span className="text-xs font-extrabold text-secondary">
                {child.xp}/{child.xp_to_next_level} XP
              </span>
            </div>
            <div className="gw-progress">
              <i style={{ width: `${xpPct}%` }} />
            </div>
          </div>
        </div>
        <Link
          href="/child/thu-chi"
          className="gw-card gw-card--press rise rise-2"
          style={{ minHeight: 128, background: "linear-gradient(150deg,#3A2F22,#241D12)", color: "#fff", border: "none", display: "block" }}
        >
          <div className="flex items-start justify-between">
            <span className="font-extrabold opacity-85 text-sm">{t(lang, "childCoins")}</span>
            <span className="grid place-items-center w-9 h-9 rounded-full bg-primary-container text-on-primary-container">
              <Icon name="savings" className="text-xl" />
            </span>
          </div>
          <div className="flex items-end gap-2 mt-4">
            <span className="text-4xl font-black leading-none">
              {child.total_coins.toLocaleString("vi-VN")}
            </span>
            <span className="font-extrabold pb-1" style={{ color: "#FFB77D" }}>
              {t(lang, "coinUnit")}
            </span>
          </div>
        </Link>
      </section>

      {/* Go to tasks (+ coins waiting to collect) */}
      <Link
        href="/child/tasks"
        className="gw-card gw-card--press rise rise-2"
        style={{ display: "flex", alignItems: "center", gap: "14px", marginBottom: "16px" }}
      >
        <span className="grid place-items-center shrink-0" style={{ width: 48, height: 48, borderRadius: 16, background: "var(--color-primary-fixed)" }}><Emoji name="clipboard" size={26} /></span>
        <div className="flex-1 min-w-0">
          <p className="font-extrabold text-on-surface">{t(lang, "navTasks")}</p>
          {pendingCoins > 0 ? (
            <p className="text-xs font-extrabold text-primary"><Emoji name="coin" size={14} /> {pendingCoins} {t(lang, "coinsPending")}</p>
          ) : (
            <p className="text-xs text-on-surface-variant">{t(lang, "hiDoTasks")}</p>
          )}
        </div>
        <Icon name="chevron_right" className="text-on-surface-variant" />
      </Link>

      {/* Achievements + streak */}
      <Link
        href="/child/achievements"
        className="gw-card gw-card--press rise rise-3"
        style={{ display: "flex", alignItems: "center", gap: "14px", marginBottom: "16px" }}
      >
        <span className="grid place-items-center shrink-0" style={{ width: 48, height: 48, borderRadius: 16, background: "var(--color-secondary-container)" }}><Emoji name="trophy" size={26} /></span>
        <div className="flex-1 min-w-0">
          <p className="font-extrabold text-on-surface">{t(lang, "viewAchievements")}</p>
          <p className="text-xs text-on-surface-variant">{badges.length} {t(lang, "badgesEarned")}</p>
        </div>
        {streak > 0 ? (
          <span className="flex items-center gap-1 font-black" style={{ color: "#E0701A", background: "#FFE9D2", borderRadius: 999, padding: "6px 12px" }}>
            <Emoji name="fire" size={18} />
            <span style={{ fontSize: 18 }}>{streak}</span>
            <span className="text-[11px] font-extrabold">{t(lang, "streakLabel")}</span>
          </span>
        ) : (
          <span className="text-[11px] text-on-surface-variant" style={{ maxWidth: 110, textAlign: "right" }}>
            {t(lang, "streakNone")}
          </span>
        )}
        <Icon name="chevron_right" className="text-on-surface-variant" />
      </Link>

      {survey && (
        <div className="mb-2 rise rise-2">
          <SurveyBanner survey={survey} childId={child.id} />
        </div>
      )}
    </div>
  );
}
