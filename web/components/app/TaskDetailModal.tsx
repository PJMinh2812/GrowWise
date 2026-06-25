"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { useLang } from "./LangProvider";
import { useToast } from "./ToastProvider";
import { updateTaskAction, deleteTaskAction } from "@/lib/app/parent-actions";
import Portal from "./Portal";
import Emoji from "@/components/Emoji";
import type { Task } from "@/lib/types";

export default function TaskDetailModal({ task, onClose }: { task: Task; onClose: () => void }) {
  const { t } = useLang();
  const { toast } = useToast();
  const router = useRouter();
  const [title, setTitle] = useState(task.title);
  const [time, setTime] = useState((task.scheduled_time ?? "").slice(0, 5));
  const [duration, setDuration] = useState(task.duration_minutes ?? 15);
  const [reward, setReward] = useState(task.coin_reward);
  const [penalty, setPenalty] = useState(task.penalty_percent);
  const [pending, start] = useTransition();

  function save() {
    start(async () => {
      const res = await updateTaskAction({
        taskId: task.id,
        title: title.trim() || task.title,
        description: task.description,
        category: task.category,
        icon: task.icon,
        coinReward: reward,
        penaltyPercent: penalty,
        scheduledTime: time || null,
        durationMinutes: duration,
      });
      if (res.ok) { toast(t("rmUpdated"), "success"); onClose(); router.refresh(); }
      else toast(res.error ?? t("toastError"), "error");
    });
  }

  function remove() {
    if (!confirm(`${t("rmDeleteTask")}: ${task.title}?`)) return;
    start(async () => {
      const res = await deleteTaskAction(task.id);
      if (res.ok) { toast(t("rmDeleted"), "success"); onClose(); router.refresh(); }
      else toast(res.error ?? t("toastError"), "error");
    });
  }

  return (
    <Portal>
    <div className="theme-parent" style={{ position: "fixed", inset: 0, zIndex: 100, background: "rgba(0,0,0,.45)", display: "flex", alignItems: "flex-end", justifyContent: "center" }} onClick={onClose}>
      <div className="gw-card" style={{ width: "100%", maxWidth: 430, borderRadius: "20px 20px 0 0", maxHeight: "90vh", overflowY: "auto", paddingBottom: 24 }} onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between mb-3">
          <b className="text-on-surface">{t("rmDetailTitle")}</b>
          <button onClick={onClose} className="text-on-surface-variant font-bold">✕</button>
        </div>

        <div className="gw-card flex items-center gap-3 mb-4" style={{ padding: "10px 12px" }}>
          <span style={{ fontSize: 26 }}>{task.icon}</span>
          <input value={title} onChange={(e) => setTitle(e.target.value)} className="gw-input" style={{ paddingLeft: 12, height: 44, flex: 1, minWidth: 0 }} />
        </div>

        <div className="grid grid-cols-2 gap-3">
          <Field label={t("rmFieldTime")}>
            <input type="time" value={time} onChange={(e) => setTime(e.target.value)} className="gw-input" style={{ paddingLeft: 12 }} />
          </Field>
          <Field label={t("rmFieldDuration")}>
            <div className="flex items-center gap-1">
              <input type="number" min={1} value={duration} onChange={(e) => setDuration(Math.max(1, parseInt(e.target.value) || 0))} className="gw-input" style={{ paddingLeft: 12 }} />
              <span className="text-xs text-on-surface-variant">{t("rmDurationMin")}</span>
            </div>
          </Field>
          <Field label={t("rmFieldReward")}>
            <div className="flex items-center gap-1">
              <Emoji name="coin" size={16} />
              <input type="number" min={0} value={reward} onChange={(e) => setReward(Math.max(0, parseInt(e.target.value) || 0))} className="gw-input" style={{ paddingLeft: 12 }} />
            </div>
          </Field>
          <Field label={t("rmFieldLate")}>
            <div className="flex items-center gap-1">
              <input type="number" min={0} max={100} value={penalty} onChange={(e) => setPenalty(Math.min(100, Math.max(0, parseInt(e.target.value) || 0)))} className="gw-input" style={{ paddingLeft: 12 }} />
              <span className="text-xs text-on-surface-variant">%</span>
            </div>
          </Field>
        </div>
        <p className="text-xs text-on-surface-variant mt-2">{t("rmFieldFrequency")}: {t("rmFreqDaily")}</p>

        <div className="flex gap-2 mt-5">
          <button onClick={remove} disabled={pending} className="gw-btn gw-btn--danger gw-btn--sm" style={{ flex: 1 }}>
            🗑 {t("rmDeleteTask")}
          </button>
          <button onClick={save} disabled={pending} className="gw-btn gw-btn--primary gw-btn--sm" style={{ flex: 1 }}>
            {pending ? "…" : t("rmSaveChanges")}
          </button>
        </div>
      </div>
    </div>
    </Portal>
  );
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div>
      <label className="block text-xs font-bold text-on-surface-variant mb-1">{label}</label>
      {children}
    </div>
  );
}
