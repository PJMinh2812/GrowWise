import { getSelectedChild, getFamilyForUser } from "@/lib/app/children";
import { getTaskTemplates } from "@/lib/app/tasks";
import { getChildSubmissions } from "@/lib/app/submissions";
import { seedRoadmapForChild } from "@/lib/app/roadmap";
import { startOfTodayVN } from "@/lib/app/day";
import RoadmapTimeline, { type TimelineItem } from "@/components/app/RoadmapTimeline";
import type { TaskStatus } from "@/lib/types";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

export default async function ChildTasksPage() {
  const lang = await getLang();
  const child = await getSelectedChild();
  if (!child) {
    return (
      <div className="gw-card mt-4 text-center">
        <p className="text-on-surface font-semibold">{t(lang, "childNoProfileShort")}</p>
      </div>
    );
  }

  const family = await getFamilyForUser();
  let templates = family ? await getTaskTemplates(family.id, child.id) : [];
  if (family && templates.length === 0) {
    await seedRoadmapForChild(child.id);
    templates = await getTaskTemplates(family.id, child.id);
  }

  const allSubs = await getChildSubmissions(child.id);
  const todayStart = startOfTodayVN().getTime();
  const yStart = todayStart - 24 * 3600 * 1000;
  const todaySubs = allSubs.filter((s) => new Date(s.created_at).getTime() >= todayStart);

  const items: TimelineItem[] = templates.map((task) => {
    const latest = todaySubs.find((s) => s.task_id === task.id);
    if (!latest || (latest.status as TaskStatus) === "pending") return { task, status: "todo" as const };
    return {
      task,
      status: latest.status as TaskStatus,
      submissionId: latest.id,
      coinEarned: latest.coin_earned ?? 0,
      collected: latest.collected ?? false,
    };
  });

  const sumEarned = (from: number, to: number) =>
    allSubs
      .filter((s) => s.status === "approved" && s.coin_earned)
      .filter((s) => {
        const ts = new Date(s.reviewed_at ?? s.created_at).getTime();
        return ts >= from && ts < to;
      })
      .reduce((sum, s) => sum + (s.coin_earned ?? 0), 0);
  const rewardToday = sumEarned(todayStart, todayStart + 24 * 3600 * 1000);
  const rewardYesterday = sumEarned(yStart, todayStart);

  // Streak: consecutive days (ending today/yesterday) with an approved task.
  const dayKey = (iso: string) => new Date(iso).toISOString().slice(0, 10);
  const doneDays = new Set(
    allSubs.filter((s) => s.status === "approved").map((s) => dayKey(s.reviewed_at ?? s.created_at)),
  );
  let streak = 0;
  const cursor = new Date();
  if (!doneDays.has(cursor.toISOString().slice(0, 10))) cursor.setDate(cursor.getDate() - 1);
  while (doneDays.has(cursor.toISOString().slice(0, 10))) {
    streak += 1;
    cursor.setDate(cursor.getDate() - 1);
  }

  return (
    <div className="pt-2">
      <RoadmapTimeline
        childId={child.id}
        items={items}
        interactive
        rewardToday={rewardToday}
        rewardYesterday={rewardYesterday}
        streak={streak}
      />
    </div>
  );
}
