"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { createTaskAction } from "@/lib/app/parent-actions";
import type { Child } from "@/lib/types";
import { useLang } from "./LangProvider";

const CATEGORIES = [
  { key: "Việc nhà", emoji: "🧹" },
  { key: "Học tập", emoji: "📚" },
  { key: "Sức khỏe", emoji: "💪" },
  { key: "Sáng tạo", emoji: "🎨" },
];

const ICONS = ["🧹", "📚", "💪", "🎨", "🍽️", "🛏️", "🪥", "🐶", "🌱", "🧺", "✏️", "🎹"];

export default function CreateTaskForm({ children }: { children: Child[] }) {
  const router = useRouter();
  const { t } = useLang();
  const [childId, setChildId] = useState(children[0]?.id ?? "");
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [category, setCategory] = useState(CATEGORIES[0].key);
  const [icon, setIcon] = useState(ICONS[0]);
  const [coinReward, setCoinReward] = useState(50);
  const [autoApprove, setAutoApprove] = useState(false);
  const [autoAfter, setAutoAfter] = useState(3);
  const [hasPenalty, setHasPenalty] = useState(false);
  const [penaltyPercent, setPenaltyPercent] = useState(10);
  const [error, setError] = useState("");
  const [pending, start] = useTransition();

  function submit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    if (!title.trim()) return setError(t("taskNameRequired"));
    start(async () => {
      const res = await createTaskAction({
        childId,
        title: title.trim(),
        description: description.trim(),
        category,
        icon,
        coinReward,
        autoApproveAfter: autoApprove ? autoAfter : null,
        hasPenalty,
        penaltyPercent,
      });
      if (res.ok) {
        router.push("/parent");
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
          <span style={{ fontSize: "18px", fontWeight: 700, color: "var(--ink)", width: "64px", textAlign: "center" }}>🪙 {coinReward}</span>
          <button type="button" onClick={() => setCoinReward((v) => v + 10)} className="gw-btn gw-btn--ghost gw-btn--sm" style={{ width: "40px", padding: 0 }}>
            +
          </button>
        </div>
      </Field>

      <Toggle
        label={t("autoApproveN")}
        checked={autoApprove}
        onChange={setAutoApprove}
      >
        <input
          type="number"
          min={1}
          value={autoAfter}
          onChange={(e) => setAutoAfter(Math.max(1, Number(e.target.value)))}
          className="gw-input"
          style={{ width: "80px" }}
        />
      </Toggle>

      <Toggle label={t("penaltyN")} checked={hasPenalty} onChange={setHasPenalty}>
        <input
          type="number"
          min={0}
          max={100}
          value={penaltyPercent}
          onChange={(e) => setPenaltyPercent(Number(e.target.value))}
          className="gw-input"
          style={{ width: "80px" }}
        />
      </Toggle>

      {error && <p style={{ fontSize: "14px", color: "var(--color-error)" }}>{error}</p>}

      <div style={{ display: "flex", gap: "12px", paddingTop: "8px" }}>
        <button
          type="button"
          onClick={() => router.push("/parent")}
          className="gw-btn gw-btn--ghost"
        >
          {t("cancel")}
        </button>
        <button
          type="submit"
          disabled={pending}
          className="gw-btn gw-btn--primary"
        >
          {pending ? t("creating") : t("navCreateTask")}
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

function Toggle({
  label,
  checked,
  onChange,
  children,
}: {
  label: string;
  checked: boolean;
  onChange: (v: boolean) => void;
  children: React.ReactNode;
}) {
  return (
    <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: "12px" }}>
      <label style={{ display: "flex", alignItems: "center", gap: "8px", fontSize: "14px", fontWeight: 600, color: "var(--ink)" }}>
        <input
          type="checkbox"
          checked={checked}
          onChange={(e) => onChange(e.target.checked)}
          className="accent-primary"
          style={{ width: "16px", height: "16px" }}
        />
        {label}
      </label>
      {checked && children}
    </div>
  );
}
