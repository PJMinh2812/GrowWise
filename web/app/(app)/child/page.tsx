import Link from "next/link";
import { getSelectedChild, getFamilyForUser } from "@/lib/app/children";
import { getTaskTemplates } from "@/lib/app/tasks";
import { getChildSubmissions } from "@/lib/app/submissions";
import ChildTaskList, { type ChildTaskItem } from "@/components/app/ChildTaskList";
import type { TaskStatus } from "@/lib/types";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

export default async function ChildHome() {
  const lang = await getLang();
  const child = await getSelectedChild();

  if (!child) {
    return (
      <div className="app-card p-6 text-center">
        <p className="text-on-surface">Chưa có hồ sơ con. Nhờ ba mẹ tạo hồ sơ giúp nhé!</p>
        <Link href="/role" className="inline-block mt-4 text-primary font-semibold underline">
          ← Quay lại chọn vai trò
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

  return (
    <div>
      <div className="mb-6">
        <div className="flex items-center gap-3">
          <span className="text-4xl">{child.avatar_emoji}</span>
          <div>
            <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface">
              {lang === "en" ? `Hi ${child.name}! ` : `Chào ${child.name}! `}
              {t(lang, "hiDoTasks")}
            </h1>
            <p className="text-sm text-on-surface-variant">
              Lv.{child.level} · 🪙 {child.total_coins.toLocaleString("vi-VN")}
            </p>
          </div>
        </div>
        <div className="mt-4 max-w-md">
          <div className="h-3 rounded-full bg-surface-container-highest overflow-hidden">
            <div className="h-full bg-primary rounded-full" style={{ width: `${xpPct}%` }} />
          </div>
          <p className="text-xs text-on-surface-variant mt-1">
            {Math.max(0, child.xp_to_next_level - child.xp)} XP nữa để lên cấp {child.level + 1}
          </p>
        </div>
      </div>

      <div className="flex items-center justify-between mb-3">
        <h2 className="text-lg font-bold text-on-surface">{t(lang, "myTasks")}</h2>
        <Link href="/child/market" className="text-sm font-semibold text-primary">
          {t(lang, "market")} →
        </Link>
      </div>

      <ChildTaskList childId={child.id} items={items} />
    </div>
  );
}
