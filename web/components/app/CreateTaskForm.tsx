"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { createTaskAction, updateTaskAction } from "@/lib/app/parent-actions";
import type { Child, Task } from "@/lib/types";
import { useLang } from "./LangProvider";
import Emoji from "@/components/Emoji";

const CATEGORIES = [
  { key: "Việc nhà", emoji: "🧹" },
  { key: "Học tập", emoji: "📚" },
  { key: "Sức khỏe", emoji: "💪" },
  { key: "Sáng tạo", emoji: "🎨" },
];

const ICONS = ["🧹", "📚", "💪", "🎨", "🍽️", "🛏️", "🪥", "🐶", "🌱", "🧺", "✏️", "🎹"];

export default function CreateTaskForm({
  children,
  task,
  onDone,
}: {
  children: Child[];
  task?: Task;
  onDone?: () => void;
}) {
  const router = useRouter();
  const { t } = useLang();
  const isEdit = Boolean(task);
  const [childId, setChildId] = useState(task?.child_id ?? children[0]?.id ?? "");
  const [title, setTitle] = useState(task?.title ?? "");
  const [description, setDescription] = useState(task?.description ?? "");
  const [category, setCategory] = useState(task?.category ?? CATEGORIES[0].key);
  const [icon, setIcon] = useState(task?.icon ?? ICONS[0]);
  const [coinReward, setCoinReward] = useState(task?.coin_reward ?? 50);
  const [scheduledTime, setScheduledTime] = useState((task?.scheduled_time ?? "").slice(0, 5));
  const [durationMinutes, setDurationMinutes] = useState(task?.duration_minutes ?? 15);
  const [error, setError] = useState("");
  const [pending, start] = useTransition();

  function submit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    if (!title.trim()) return setError(t("taskNameRequired"));
    start(async () => {
      // Roadmap tasks always auto-approve (credited at day-end / on approval) and
      // carry a default 10% late penalty — no manual toggles needed.
      const res = isEdit
        ? await updateTaskAction({
            taskId: task!.id,
            title: title.trim(),
            description: description.trim(),
            category,
            icon,
            coinReward,
            autoApprove: true,
            hasPenalty: true,
            penaltyPercent: 10,
            scheduledTime: scheduledTime || null,
            durationMinutes,
          })
        : await createTaskAction({
            childId,
            title: title.trim(),
            description: description.trim(),
            category,
            icon,
            coinReward,
            autoApproveAfter: 0,
            hasPenalty: true,
            penaltyPercent: 10,
            scheduledTime: scheduledTime || null,
            durationMinutes,
          });
      if (res.ok) {
        if (onDone) onDone();
        else router.push("/parent");
        router.refresh();
      } else {
        setError(res.error ?? t("createTaskError"));
      }
    });
  }

  return (
    <form onSubmit={submit} className="gw-card" style={{ maxWidth: "560px", display: "flex", flexDirection: "column", gap: "20px" }}>
      {children.length > 1 && (
        <Field label={t("assignToChild")}>
          <select
            value={childId}
            onChange={(e) => setChildId(e.target.value)}
            className="gw-input"
          >
            {children.map((c) => (
              <option key={c.id} value={c.id}>
                {c.avatar_emoji} {c.name}
              </option>
            ))}
          </select>
        </Field>
      )}

      <Field label={t("taskName")}>
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="VD: Dọn phòng ngủ"
          className="gw-input"
        />
      </Field>

      <Field label={t("taskDescription")}>
        <textarea
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          rows={2}
          placeholder="Hướng dẫn ngắn cho con…"
          className="gw-input"
        />
      </Field>

      <Field label={t("taskCategory")}>
        <div style={{ display: "flex", flexWrap: "wrap", gap: "8px" }}>
          {CATEGORIES.map((c) => (
            <button
              key={c.key}
              type="button"
              onClick={() => setCategory(c.key)}
              className={`gw-btn gw-btn--sm ${category === c.key ? "gw-btn--primary" : "gw-btn--ghost"}`}
            >
              {c.emoji} {c.key}
            </button>
          ))}
        </div>
      </Field>

      <Field label={t("taskIcon")}>
        <div style={{ display: "flex", flexWrap: "wrap", gap: "8px" }}>
          {ICONS.map((ic) => (
            <button
              key={ic}
              type="button"
              onClick={() => setIcon(ic)}
              style={{
                width: "40px", height: "40px", borderRadius: "12px", fontSize: "20px",
                border: ic === icon ? "2px solid var(--primary-c)" : "1.5px solid var(--outline-v)",
                background: ic === icon ? "var(--primary-fixed)" : "var(--white)",
                cursor: "pointer",
              }}
            >
              {ic}
            </button>
          ))}
        </div>
      </Field>

      <Field label={t("taskReward")}>
        <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
          <button type="button" onClick={() => setCoinReward((v) => Math.max(0, v - 10))} className="gw-btn gw-btn--ghost gw-btn--sm" style={{ width: "40px", padding: 0 }}>
            −
          </button>
          <span style={{ fontSize: "18px", fontWeight: 700, color: "var(--ink)", width: "64px", textAlign: "center", display: "inline-flex", alignItems: "center", justifyContent: "center", gap: "6px" }}><Emoji name="coin" size={18} /> {coinReward}</span>
          <button type="button" onClick={() => setCoinReward((v) => v + 10)} className="gw-btn gw-btn--ghost gw-btn--sm" style={{ width: "40px", padding: 0 }}>
            +
          </button>
        </div>
      </Field>

      <div style={{ display: "flex", gap: "12px" }}>
        <Field label={t("rmFieldTime")}>
          <input type="time" value={scheduledTime} onChange={(e) => setScheduledTime(e.target.value)} className="gw-input" style={{ paddingLeft: 14 }} />
        </Field>
        <Field label={t("rmFieldDuration")}>
          <input type="number" min={1} value={durationMinutes} onChange={(e) => setDurationMinutes(Math.max(1, parseInt(e.target.value) || 0))} className="gw-input" style={{ paddingLeft: 14 }} />
        </Field>
      </div>

      {error && <p style={{ fontSize: "14px", color: "var(--color-error)" }}>{error}</p>}

      <div style={{ display: "flex", gap: "12px", paddingTop: "8px" }}>
        <button
          type="button"
          onClick={() => (onDone ? onDone() : router.push("/parent"))}
          className="gw-btn gw-btn--ghost"
        >
          {t("cancel")}
        </button>
        <button
          type="submit"
          disabled={pending}
          className="gw-btn gw-btn--primary"
        >
          {pending ? t("creating") : isEdit ? t("rmUpdated") : t("navCreateTask")}
        </button>
      </div>
    </form>
  );
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div>
      <label style={{ display: "block", fontSize: "14px", fontWeight: 600, color: "var(--ink)", marginBottom: "6px" }}>{label}</label>
      {children}
    </div>
  );
}

