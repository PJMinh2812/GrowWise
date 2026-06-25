import Link from "next/link";
import { getFamilyForUser, getChildren } from "@/lib/app/children";
import { getTaskTemplates } from "@/lib/app/tasks";
import { getChildSubmissions } from "@/lib/app/submissions";
import { startOfTodayVN } from "@/lib/app/day";
import RoadmapTimeline, { type TimelineItem } from "@/components/app/RoadmapTimeline";
import Icon from "@/components/Icon";
import type { TaskStatus } from "@/lib/types";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

export default async function ParentChildTimelinePage({
  searchParams,
}: {
  searchParams: Promise<{ child?: string }>;
}) {
  const lang = await getLang();
  const { child: childParam } = await searchParams;
  const family = await getFamilyForUser();
  const children = family ? await getChildren(family.id) : [];
  const child = children.find((c) => c.id === childParam) ?? children[0];

  if (!child) {
    return <div className="gw-card mt-4" style={{ padding: 24 }}>{t(lang, "needChildProfileMsg")}</div>;
  }

  const templates = family ? await getTaskTemplates(family.id, child.id) : [];
  const allSubs = await getChildSubmissions(child.id);
  const todayStart = startOfTodayVN().getTime();
  const todaySubs = allSubs.filter((s) => new Date(s.created_at).getTime() >= todayStart);

  const items: TimelineItem[] = templates.map((task) => {
    const latest = todaySubs.find((s) => s.task_id === task.id);
    if (!latest || (latest.status as TaskStatus) === "pending") return { task, status: "todo" as const };
    return { task, status: latest.status as TaskStatus, submissionId: latest.id, coinEarned: latest.coin_earned ?? 0 };
  });

  const rewardToday = todaySubs
    .filter((s) => s.status === "approved")
    .reduce((sum, s) => sum + (s.coin_earned ?? 0), 0);

  return (
    <div className="pt-2">
      <div className="flex items-center gap-2 mb-3">
        <Link href="/parent/roadmap" aria-label="back" className="text-on-surface-variant">
          <Icon name="arrow_back" className="text-xl" />
        </Link>
        <h1 className="font-black text-on-surface" style={{ fontSize: 18 }}>
          {t(lang, "rmChildTimelineTitle")} · {child.avatar_emoji} {child.name}
        </h1>
      </div>

      {children.length > 1 && (
        <div className="flex gap-2 mb-3 flex-wrap">
          {children.map((c) => (
            <Link key={c.id} href={`/parent/roadmap/timeline?child=${c.id}`} className={`gw-chip${c.id === child.id ? " active" : ""}`} style={{ display: "inline-flex", alignItems: "center", gap: 6 }}>
              <span>{c.avatar_emoji}</span> {c.name}
            </Link>
          ))}
        </div>
      )}

      <RoadmapTimeline childId={child.id} items={items} rewardToday={rewardToday} />
    </div>
  );
}
