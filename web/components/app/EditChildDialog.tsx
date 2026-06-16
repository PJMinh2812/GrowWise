"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { updateChildAction } from "@/lib/app/parent-actions";
import { useLang } from "./LangProvider";

const AVATARS = ["👦", "👧", "🧒", "👶", "🐱", "🐶", "🦊", "🐼", "🦄", "🐯"];

export default function EditChildDialog({
  child,
  onClose,
}: {
  child: { id: string; name: string; age: number; emoji: string };
  onClose: () => void;
}) {
  const router = useRouter();
  const { t } = useLang();
  const [name, setName] = useState(child.name);
  const [age, setAge] = useState(child.age || 8);
  const [emoji, setEmoji] = useState(child.emoji || AVATARS[0]);
  const [error, setError] = useState("");
  const [pending, start] = useTransition();

  function submit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    if (!name.trim()) {
      setError(t("nameRequired"));
      return;
    }
    start(async () => {
      const res = await updateChildAction({ childId: child.id, name: name.trim(), age, avatarEmoji: emoji });
      if (res.ok) {
        onClose();
        router.refresh();
      } else {
        setError(res.error ?? "Lỗi");
      }
    });
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
      <form onSubmit={submit} className="app-card w-full max-w-sm p-6">
        <h3 className="text-lg font-bold text-on-surface mb-4">Sửa thông tin con</h3>

        <div className="flex flex-wrap gap-2 mb-4">
          {AVATARS.map((a) => (
            <button
              key={a}
              type="button"
              onClick={() => setEmoji(a)}
              className={`w-9 h-9 rounded-[12px] text-lg border ${
                emoji === a ? "border-primary bg-primary-container/20" : "border-outline-variant"
              }`}
            >
              {a}
            </button>
          ))}
        </div>

        <label className="block text-sm font-semibold text-on-surface mb-1">{t("childName")}</label>
        <input
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="Tên con"
          className="w-full border border-outline-variant rounded-[14px] px-3 py-2.5 text-on-surface mb-3"
        />

        <label className="block text-sm font-semibold text-on-surface mb-1">{t("childAge")}</label>
        <input
          type="number"
          min={1}
          max={17}
          value={age}
          onChange={(e) => setAge(Number(e.target.value))}
          className="w-full border border-outline-variant rounded-[14px] px-3 py-2.5 text-on-surface mb-3"
        />

        {error && <p className="text-sm text-error mb-3">{error}</p>}

        <div className="flex gap-2 mt-2">
          <button
            type="button"
            onClick={onClose}
            className="flex-1 py-2.5 rounded-[14px] bg-surface-container text-on-surface-variant font-semibold"
          >
            {t("cancel")}
          </button>
          <button
            type="submit"
            disabled={pending}
            className="flex-1 py-2.5 rounded-[14px] bg-primary text-on-primary font-bold disabled:opacity-50"
          >
            {pending ? t("saving") : t("save")}
          </button>
        </div>
      </form>
    </div>
  );
}
