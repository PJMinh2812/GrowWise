import Link from "next/link";
import { getSelectedChild, getFamilyForUser } from "@/lib/app/children";
import { getTaskTemplates } from "@/lib/app/tasks";
import { getTodaySubmissions } from "@/lib/app/submissions";
import { seedRoadmapForChild } from "@/lib/app/roadmap";
import ChildTaskList, { type ChildTaskItem } from "@/components/app/ChildTaskList";
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

  // Auto-run the age roadmap: if the child has no tasks yet, seed them so a busy
  // parent doesn't have to. Idempotent on the action side.
  if (family && templates.length === 0) {
    await seedRoadmapForChild(child.id);
    templates = await getTaskTemplates(family.id, child.id);
  }

  const submissions = await getTodaySubmissions(child.id);
  const items: ChildTaskItem[] = templates.map((task) => {
    const latest = submissions.find((s) => s.task_id === task.id);
    if (!latest) return { task, status: "todo" as const };
    const st = latest.status as TaskStatus;
    if (st === "pending") return { task, status: "todo" as const };
    return {
      task,
      status: st,
      parentNote: latest.parent_note,
      submissionId: latest.id,
      coinEarned: latest.coin_earned ?? 0,
      collected: latest.collected ?? false,
    };
  });

  return (
    <div className="pt-4">
      <div className="gw-h">
        <h2>{t(lang, "tasksPageTitle")}</h2>
        <Link href="/child/market">{t(lang, "market")} →</Link>
      </div>
      <ChildTaskList childId={child.id} items={items} />
    </div>
  );
}
