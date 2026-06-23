import Link from "next/link";
import { getSelectedChild, getFamilyForUser } from "@/lib/app/children";
import { getTaskTemplates } from "@/lib/app/tasks";
import { getChildSubmissions } from "@/lib/app/submissions";
import ChildTaskList, { type ChildTaskItem } from "@/components/app/ChildTaskList";
import SurveyBanner from "@/components/app/SurveyBanner";
import { getActiveSurveyFor } from "@/lib/app/surveys";
import type { TaskStatus } from "@/lib/types";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

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

  const family = await getFamilyForUser();
  const [templates, submissions] = await Promise.all([
    family ? getTaskTemplates(family.id, child.id) : Promise.resolve([]),
    getChildSubmissions(child.id),
  ]);

  // Merge each template with its latest submission to derive a status.
  const items: ChildTaskItem[] = templates.map((task) => {
    const latest = submissions.find((s) => s.task_id === task.id);
    if (!latest) return { task, status: "todo" as const };
    const st = latest.status as TaskStatus;
    if (st === "pending") return { task, status: "todo" as const };
    return { task, status: st, parentNote: latest.parent_note };
  });

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
              <span className="material-symbols-outlined text-xl">star</span>
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
        <div
          className="gw-card gw-card--press rise rise-2"
          style={{ minHeight: 128, background: "linear-gradient(150deg,#3A2F22,#241D12)", color: "#fff", border: "none" }}
        >
          <div className="flex items-start justify-between">
            <span className="font-extrabold opacity-85 text-sm">{t(lang, "childCoins")}</span>
            <span className="grid place-items-center w-9 h-9 rounded-full bg-primary-container text-on-primary-container">
              <span className="material-symbols-outlined text-xl">savings</span>
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
        </div>
      </section>

      {survey && (
        <div className="mb-2 rise rise-2">
          <SurveyBanner survey={survey} childId={child.id} />
        </div>
      )}

      {/* Tasks */}
      <section className="mt-4 rise rise-3">
        <div className="gw-h">
          <h2>{t(lang, "myTasks")}</h2>
          <Link href="/child/market">{t(lang, "market")} →</Link>
        </div>
        <ChildTaskList childId={child.id} items={items} />
      </section>
    </div>
  );
}
