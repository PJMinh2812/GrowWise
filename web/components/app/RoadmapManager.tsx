"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { useLang } from "./LangProvider";
import { useToast } from "./ToastProvider";
import { setTaskActiveAction } from "@/lib/app/parent-actions";
import TaskDetailModal from "./TaskDetailModal";
import Emoji from "@/components/Emoji";
import type { Child, Task } from "@/lib/types";

export default function RoadmapManager({ children, tasks }: { children: Child[]; tasks: Task[] }) {
  const { t } = useLang();
  const { toast } = useToast();
  const router = useRouter();
  const [pending, start] = useTransition();
  const [detail, setDetail] = useState<Task | null>(null);

  if (children.length === 0) return null;

  function toggle(task: Task) {
    start(async () => {
      const res = await setTaskActiveAction(task.id, !task.is_active);
      if (!res.ok) toast(res.error ?? t("toastError"), "error");
      router.refresh();
    });
  }

  return (
    <div className="mb-6">
      <div className="flex items-center justify-between mb-2">
        <h2 className="font-extrabold text-on-surface">{t("rmCurrentRoadmap")}</h2>
      </div>
      {children.map((c) => {
        const list = [...tasks.filter((tk) => tk.child_id === c.id)].sort((a, b) =>
          (a.scheduled_time ?? "99").localeCompare(b.scheduled_time ?? "99"),
        );
        return (
          <div key={c.id} className="mb-4">
            {children.length > 1 && (
              <p className="font-bold text-on-surface-variant mb-2" style={{ display: "flex", alignItems: "center", gap: 6 }}>
                <span>{c.avatar_emoji}</span> {c.name}
              </p>
            )}
            {list.length === 0 ? (
              <p className="text-sm text-on-surface-variant">{t("rmNoTasks")}</p>
            ) : (
              <div className="space-y-2">
                {list.map((task) => (
                  <div key={task.id} className="gw-card" style={{ padding: "10px 12px", display: "flex", alignItems: "center", gap: 10, opacity: task.is_active ? 1 : 0.5 }}>
                    <span style={{ fontSize: 22 }}>{task.icon}</span>
                    <div className="flex-1 min-w-0">
                      <p className="font-extrabold text-on-surface truncate">{task.title}</p>
                      <p className="text-xs text-on-surface-variant" style={{ display: "flex", alignItems: "center", gap: 4, flexWrap: "wrap" }}>
                        {task.scheduled_time ? `${task.scheduled_time.slice(0, 5)} · ` : ""}
                        <Emoji name="coin" size={13} /> {task.coin_reward}
                        {task.has_penalty ? ` · −${task.penalty_percent}% ${t("rmLateShort")}` : ""}
                        {` · ${t("rmFreqDaily")}`}
                      </p>
                    </div>
                    <button
                      onClick={() => toggle(task)}
                      disabled={pending}
                      role="switch"
                      aria-checked={task.is_active}
                      className="shrink-0"
                      style={{
                        width: 44, height: 26, borderRadius: 999, position: "relative",
                        background: task.is_active ? "var(--color-primary)" : "var(--color-outline-variant)",
                        transition: ".15s",
                      }}
                      title={task.is_active ? t("rmTaskActive") : t("rmTaskInactive")}
                    >
                      <span style={{ position: "absolute", top: 3, left: task.is_active ? 21 : 3, width: 20, height: 20, borderRadius: "50%", background: "#fff", transition: ".15s" }} />
                    </button>
                    <button onClick={() => setDetail(task)} disabled={pending} aria-label={t("rmDetailTitle")} className="shrink-0 text-on-surface-variant" style={{ fontSize: 20, fontWeight: 900, lineHeight: 1, padding: "0 4px" }}>
                      ⋮
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>
        );
      })}

      {detail && <TaskDetailModal task={detail} onClose={() => setDetail(null)} />}
    </div>
  );
}
