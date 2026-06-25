"use client";

import { useMemo, useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";
import { submitTask } from "@/lib/app/child-actions";
import { celebrate } from "@/lib/app/feedback";
import { useLang } from "./LangProvider";
import { useToast } from "./ToastProvider";
import CameraCapture from "./CameraCapture";
import SuggestTasksModal from "./SuggestTasksModal";
import Emoji from "@/components/Emoji";
import Icon from "@/components/Icon";
import type { Task, TaskStatus } from "@/lib/types";

export interface TimelineItem {
  task: Task;
  status: TaskStatus | "todo";
  submissionId?: string;
  collected?: boolean;
  coinEarned?: number;
}

const DAY_LABELS = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];

function hhmm(time: string | null): string {
  if (!time) return "";
  return time.slice(0, 5);
}

export default function RoadmapTimeline({
  childId,
  items,
  interactive = false,
  rewardToday = 0,
  rewardYesterday = 0,
  streak = 0,
}: {
  childId: string;
  items: TimelineItem[];
  interactive?: boolean;
  rewardToday?: number;
  rewardYesterday?: number;
  streak?: number;
}) {
  const { t } = useLang();

  // Week strip (Mon–Sun) with today highlighted.
  const week = useMemo(() => {
    const now = new Date();
    const dow = (now.getDay() + 6) % 7; // 0 = Monday
    const monday = new Date(now);
    monday.setDate(now.getDate() - dow);
    return Array.from({ length: 7 }, (_, i) => {
      const d = new Date(monday);
      d.setDate(monday.getDate() + i);
      return { label: DAY_LABELS[i], date: d.getDate(), today: i === dow };
    });
  }, []);

  const sorted = useMemo(
    () =>
      [...items].sort((a, b) =>
        (a.task.scheduled_time ?? "99:99").localeCompare(b.task.scheduled_time ?? "99:99"),
      ),
    [items],
  );

  // The "current" task = first not-done (by time).
  const currentId = sorted.find((i) => i.status === "todo" || i.status === "rejected")?.task.id;
  const doneCount = items.filter((i) => i.status === "approved" || i.status === "submitted").length;
  const delta = rewardToday - rewardYesterday;
  const [suggest, setSuggest] = useState(false);

  return (
    <div className="pt-2">
      {/* Week strip */}
      <div className="flex justify-between mb-4">
        {week.map((d, i) => (
          <div key={i} className="flex flex-col items-center gap-1" style={{ flex: 1 }}>
            <span className="text-[11px] font-bold text-on-surface-variant">{d.label}</span>
            <span
              className="grid place-items-center font-extrabold"
              style={{
                width: 34, height: 34, borderRadius: "50%", fontSize: 14,
                background: d.today ? "var(--color-primary)" : "transparent",
                color: d.today ? "#fff" : "var(--color-on-surface)",
              }}
            >
              {d.date}
            </span>
          </div>
        ))}
      </div>

      <div className="flex items-center justify-between mb-3">
        <h2 className="font-black text-on-surface" style={{ fontSize: 18 }}>{t("rmToday")}</h2>
        <span className="inline-flex items-center gap-1 font-extrabold" style={{ background: "#FFF1D6", color: "#C77700", borderRadius: 999, padding: "4px 12px", fontSize: 13 }}>
          <Emoji name="star" size={15} /> {doneCount}/{items.length} {t("rmTasksCount")}
        </span>
      </div>

      {/* Timeline */}
      <div className="space-y-0">
        {sorted.map((item, idx) => (
          <TimelineRow
            key={item.task.id}
            item={item}
            childId={childId}
            interactive={interactive}
            isCurrent={item.task.id === currentId}
            isLast={idx === sorted.length - 1}
          />
        ))}
        {items.length === 0 && (
          <div className="gw-card text-center text-on-surface-variant font-semibold py-8">{t("taskEmpty")}</div>
        )}
      </div>

      {/* Reward + streak */}
      <div className="grid grid-cols-2 gap-3 mt-5">
        <div className="gw-card" style={{ padding: 14, background: "#FFF8EE" }}>
          <p className="text-xs font-bold text-on-surface-variant">{t("rmRewardToday")}</p>
          <p className="font-black text-on-surface mt-1" style={{ fontSize: 26, display: "inline-flex", alignItems: "center", gap: 6 }}>
            {rewardToday} <Emoji name="coin" size={22} />
          </p>
          {delta !== 0 && (
            <p className="text-xs font-extrabold mt-0.5" style={{ color: delta > 0 ? "#1F8A4C" : "#C0392B" }}>
              {delta > 0 ? "+" : ""}{delta} {t("rmVsYesterday")}
            </p>
          )}
        </div>
        <div className="gw-card" style={{ padding: 14, background: "#FFF8EE" }}>
          <p className="text-xs font-bold text-on-surface-variant">{t("rmStreakTitle")}</p>
          <p className="font-black text-on-surface mt-1" style={{ fontSize: 26, display: "inline-flex", alignItems: "center", gap: 6 }}>
            <Emoji name="fire" size={22} /> {streak} {t("rmStreakDays")}
          </p>
          {streak > 0 && <p className="text-xs font-extrabold text-primary mt-0.5">{t("rmStreakGreat")}</p>}
        </div>
      </div>

      {interactive && (
        <button onClick={() => setSuggest(true)} className="gw-btn gw-btn--ghost mt-4">
          <Emoji name="sparkles" size={16} /> {t("rmSuggestMore")}
        </button>
      )}
      {suggest && <SuggestTasksModal childId={childId} onClose={() => setSuggest(false)} />}
    </div>
  );
}

function TimelineRow({
  item,
  childId,
  interactive,
  isCurrent,
  isLast,
}: {
  item: TimelineItem;
  childId: string;
  interactive: boolean;
  isCurrent: boolean;
  isLast: boolean;
}) {
  const { t } = useLang();
  const { toast } = useToast();
  const router = useRouter();
  const [showCamera, setShowCamera] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [, start] = useTransition();
  const { task } = item;

  const done = item.status === "approved" || item.status === "submitted";
  const missed = item.status === "missed";
  const actionable = interactive && (item.status === "todo" || item.status === "rejected");

  // dot color
  const dot = done
    ? { bg: "var(--color-primary)", ring: false, check: true }
    : missed
      ? { bg: "#E0E0E0", ring: false, check: false }
      : isCurrent
        ? { bg: "#fff", ring: true, check: false }
        : { bg: "#E0E0E0", ring: false, check: false };

  async function handleFile(file: File) {
    setShowCamera(false);
    setUploading(true);
    try {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error(t("sessionExpired"));
      const path = `${user.id}/${task.id}-${Date.now()}.jpg`;
      const { error: upErr } = await supabase.storage
        .from("task-proofs")
        .upload(path, file, { contentType: file.type || "image/jpeg", upsert: true });
      if (upErr) throw upErr;
      const url = supabase.storage.from("task-proofs").getPublicUrl(path).data.publicUrl;
      start(async () => {
        const res = await submitTask({ taskId: task.id, childId, proofUrl: url });
        if (!res.ok) { toast(res.error ?? t("toastError"), "error"); return; }
        celebrate();
        toast(t("submitWaitDayEnd"), "success");
        router.refresh();
      });
    } catch (err) {
      toast(err instanceof Error ? err.message : t("toastError"), "error");
    } finally {
      setUploading(false);
    }
  }

  return (
    <div className="flex gap-3" style={{ minHeight: 76 }}>
      {/* time + dot rail */}
      <div className="flex flex-col items-center" style={{ width: 52 }}>
        <span className="text-[11px] font-extrabold text-on-surface-variant" style={{ height: 16 }}>{hhmm(task.scheduled_time)}</span>
        <span
          className="grid place-items-center shrink-0"
          style={{
            width: 28, height: 28, borderRadius: "50%", marginTop: 2,
            background: dot.bg,
            border: dot.ring ? "3px solid var(--color-primary)" : "none",
            color: "#fff",
          }}
        >
          {dot.check && <Icon name="check_circle" weight="fill" className="text-base" />}
        </span>
        {!isLast && <span style={{ flex: 1, width: 2, background: "var(--color-outline-variant)", marginTop: 2 }} />}
      </div>

      {/* card */}
      <div
        className={`gw-card flex-1 mb-3 ${actionable ? "gw-card--press" : ""}`}
        style={{ padding: "12px 14px", opacity: missed ? 0.6 : 1, cursor: actionable ? "pointer" : "default", borderColor: isCurrent ? "var(--color-primary)" : undefined }}
        onClick={() => actionable && !uploading && setShowCamera(true)}
      >
        <div className="flex items-center gap-3">
          <span style={{ fontSize: 24 }}>{task.icon}</span>
          <div className="flex-1 min-w-0">
            <p className="font-extrabold text-on-surface truncate">{task.title}</p>
            <p className="text-xs text-on-surface-variant" style={{ display: "flex", alignItems: "center", gap: 4, flexWrap: "wrap" }}>
              <Emoji name="coin" size={13} /> {task.coin_reward}
              {task.has_penalty ? ` · −${task.penalty_percent}% ${t("rmLateShort")}` : ""}
              {task.duration_minutes ? ` · ${task.duration_minutes} ${t("rmDurationMin")}` : ""}
            </p>
          </div>
          {done ? (
            <Icon name="check_circle" weight="fill" className="text-primary text-2xl" />
          ) : missed ? (
            <Icon name="close" className="text-error text-xl" />
          ) : isCurrent ? (
            <Icon name="schedule" className="text-primary text-xl" />
          ) : (
            <span style={{ width: 22, height: 22, borderRadius: "50%", border: "2px solid var(--color-outline-variant)" }} />
          )}
        </div>
      </div>

      {showCamera && <CameraCapture onCapture={handleFile} onClose={() => setShowCamera(false)} />}
    </div>
  );
}
