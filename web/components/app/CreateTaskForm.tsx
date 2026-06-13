"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { createTaskAction } from "@/lib/app/parent-actions";
import type { Child } from "@/lib/types";

const CATEGORIES = [
  { key: "Việc nhà", emoji: "🧹" },
  { key: "Học tập", emoji: "📚" },
  { key: "Sức khỏe", emoji: "💪" },
  { key: "Sáng tạo", emoji: "🎨" },
];

const ICONS = ["🧹", "📚", "💪", "🎨", "🍽️", "🛏️", "🪥", "🐶", "🌱", "🧺", "✏️", "🎹"];

export default function CreateTaskForm({ children }: { children: Child[] }) {
  const router = useRouter();
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
    if (!title.trim()) return setError("Nhập tên nhiệm vụ.");
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
        setError(res.error ?? "Không tạo được nhiệm vụ.");
      }
    });
  }

  return (
    <form onSubmit={submit} className="app-card p-6 max-w-xl space-y-5">
      {children.length > 1 && (
        <Field label="Giao cho con">
          <select
            value={childId}
            onChange={(e) => setChildId(e.target.value)}
            className="input"
          >
            {children.map((c) => (
              <option key={c.id} value={c.id}>
                {c.avatar_emoji} {c.name}
              </option>
            ))}
          </select>
        </Field>
      )}

      <Field label="Tên nhiệm vụ">
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="VD: Dọn phòng ngủ"
          className="input"
        />
      </Field>

      <Field label="Mô tả">
        <textarea
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          rows={2}
          placeholder="Hướng dẫn ngắn cho con…"
          className="input"
        />
      </Field>

      <Field label="Danh mục">
        <div className="flex flex-wrap gap-2">
          {CATEGORIES.map((c) => (
            <button
              key={c.key}
              type="button"
              onClick={() => setCategory(c.key)}
              className={`px-3 py-2 rounded-[14px] text-sm font-semibold border ${
                category === c.key
                  ? "bg-primary text-on-primary border-primary"
                  : "bg-surface-container-low text-on-surface-variant border-outline-variant"
              }`}
            >
              {c.emoji} {c.key}
            </button>
          ))}
        </div>
      </Field>

      <Field label="Biểu tượng">
        <div className="flex flex-wrap gap-2">
          {ICONS.map((ic) => (
            <button
              key={ic}
              type="button"
              onClick={() => setIcon(ic)}
              className={`w-10 h-10 rounded-[14px] text-xl border ${
                icon === ic ? "border-primary bg-primary-container/20" : "border-outline-variant"
              }`}
            >
              {ic}
            </button>
          ))}
        </div>
      </Field>

      <Field label="Phần thưởng (xu)">
        <div className="flex items-center gap-3">
          <button type="button" onClick={() => setCoinReward((v) => Math.max(0, v - 10))} className="stepper">
            −
          </button>
          <span className="text-lg font-bold text-on-surface w-16 text-center">🪙 {coinReward}</span>
          <button type="button" onClick={() => setCoinReward((v) => v + 10)} className="stepper">
            +
          </button>
        </div>
      </Field>

      <Toggle
        label="Tự động duyệt sau N lần"
        checked={autoApprove}
        onChange={setAutoApprove}
      >
        <input
          type="number"
          min={1}
          value={autoAfter}
          onChange={(e) => setAutoAfter(Math.max(1, Number(e.target.value)))}
          className="input w-20"
        />
      </Toggle>

      <Toggle label="Phạt nếu bỏ dở (%)" checked={hasPenalty} onChange={setHasPenalty}>
        <input
          type="number"
          min={0}
          max={100}
          value={penaltyPercent}
          onChange={(e) => setPenaltyPercent(Number(e.target.value))}
          className="input w-20"
        />
      </Toggle>

      {error && <p className="text-sm text-error">{error}</p>}

      <div className="flex gap-3 pt-2">
        <button
          type="button"
          onClick={() => router.push("/parent")}
          className="px-5 py-2.5 rounded-[14px] bg-surface-container text-on-surface-variant font-semibold"
        >
          Huỷ
        </button>
        <button
          type="submit"
          disabled={pending}
          className="px-6 py-2.5 rounded-[14px] bg-primary text-on-primary font-bold disabled:opacity-50"
        >
          {pending ? "Đang tạo…" : "Tạo nhiệm vụ"}
        </button>
      </div>

      <style jsx>{`
        :global(.input) {
          width: 100%;
          border: 1px solid var(--color-outline-variant);
          border-radius: 14px;
          padding: 0.6rem 0.75rem;
          font-size: 0.9rem;
          color: var(--color-on-surface);
          background: var(--color-surface-container-lowest);
        }
        :global(.stepper) {
          width: 2.5rem;
          height: 2.5rem;
          border-radius: 14px;
          background: var(--color-surface-container);
          font-size: 1.25rem;
          font-weight: 700;
          color: var(--color-on-surface);
        }
      `}</style>
    </form>
  );
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div>
      <label className="block text-sm font-semibold text-on-surface mb-1.5">{label}</label>
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
    <div className="flex items-center justify-between gap-3">
      <label className="flex items-center gap-2 text-sm font-semibold text-on-surface">
        <input
          type="checkbox"
          checked={checked}
          onChange={(e) => onChange(e.target.checked)}
          className="accent-primary w-4 h-4"
        />
        {label}
      </label>
      {checked && children}
    </div>
  );
}
