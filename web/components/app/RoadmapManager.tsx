"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { useLang } from "./LangProvider";
import { useToast } from "./ToastProvider";
import { setTaskActiveAction, deleteTaskAction } from "@/lib/app/parent-actions";
import CreateTaskForm from "./CreateTaskForm";
import Emoji from "@/components/Emoji";
import Icon from "@/components/Icon";
import type { Child, Task } from "@/lib/types";

export default function RoadmapManager({ children, tasks }: { children: Child[]; tasks: Task[] }) {
  const { t } = useLang();
  const { toast } = useToast();
  const router = useRouter();
  const [pending, start] = useTransition();
  const [editing, setEditing] = useState<Task | null>(null);

  if (children.length === 0) return null;

  function toggle(task: Task) {
    start(async () => {
      const res = await setTaskActiveAction(task.id, !task.is_active);
      if (!res.ok) toast(res.error ?? t("toastError"), "error");
      router.refresh();
    });
  }

  function remove(task: Task) {
    if (!confirm(`${t("rmTaskDelete")}: ${task.title}?`)) return;
    start(async () => {
      const res = await deleteTaskAction(task.id);
      if (res.ok) toast(t("rmDeleted"), "success");
      else toast(res.error ?? t("toastError"), "error");
      router.refresh();
    });
  }

  return (
    <div className="mb-6">
      <h2 className="font-extrabold text-on-surface mb-2">{t("rmExistingTasks")}</h2>
      {children.map((c) => {
        const list = tasks.filter((tk) => tk.child_id === c.id);
        return (
          <div key={c.id} className="mb-4">
            <p className="font-bold text-on-surface-variant mb-2" style={{ display: "flex", alignItems: "center", gap: 6 }}>
              <span>{c.avatar_emoji}</span> {c.name}
            </p>
            {list.length === 0 ? (
              <p className="text-sm text-on-surface-variant">{t("rmNoTasks")}</p>
            ) : (
              <div className="space-y-2">
                {list.map((task) => (
                  <div key={task.id} className="gw-card" style={{ padding: "10px 12px", display: "flex", alignItems: "center", gap: 10, opacity: task.is_active ? 1 : 0.55 }}>
                    <span style={{ fontSize: 22 }}>{task.icon}</span>
                    <div className="flex-1 min-w-0">
                      <p className="font-extrabold text-on-surface truncate">{task.title}</p>
                      <p className="text-xs text-on-surface-variant" style={{ display: "flex", alignItems: "center", gap: 4 }}>
                        <Emoji name="coin" size={13} /> {task.coin_reward}
                        {task.has_penalty ? ` · −${task.penalty_percent}%` : ""}
                        {task.auto_approve_after != null ? ` · ${t("rmAutoApprove")}` : ""}
                      </p>
                    </div>
                    <button onClick={() => toggle(task)} disabled={pending} className="gw-chip" title={task.is_active ? t("rmTaskActive") : t("rmTaskInactive")}>
                      {task.is_active ? t("rmTaskActive") : t("rmTaskInactive")}
                    </button>
                    <button onClick={() => setEditing(task)} disabled={pending} aria-label={t("rmTaskEdit")} className="shrink-0 text-on-surface-variant">
                      <Icon name="edit" />
                    </button>
                    <button onClick={() => remove(task)} disabled={pending} aria-label={t("rmTaskDelete")} className="shrink-0 text-error">
                      <Icon name="delete" />
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>
        );
      })}

      {editing && (
        <div style={{ position: "fixed", inset: 0, zIndex: 60, background: "rgba(0,0,0,.45)", display: "flex", alignItems: "flex-start", justifyContent: "center", padding: 16, overflowY: "auto" }} onClick={() => setEditing(null)}>
          <div style={{ width: "100%", maxWidth: 560, marginTop: 24 }} onClick={(e) => e.stopPropagation()}>
            <CreateTaskForm
              children={children.filter((c) => c.id === editing.child_id)}
              task={editing}
              onDone={() => setEditing(null)}
            />
          </div>
        </div>
      )}
    </div>
  );
}
