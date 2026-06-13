"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { addChildAction } from "@/lib/app/parent-actions";
import { useLang } from "./LangProvider";

const AVATARS = ["👦", "👧", "🧒", "👶", "🐱", "🐶", "🦊", "🐼", "🦄", "🐯"];

export default function AddChildDialog({ onClose }: { onClose: () => void }) {
  const router = useRouter();
  const { t } = useLang();
  const [name, setName] = useState("");
  const [age, setAge] = useState(8);
  const [emoji, setEmoji] = useState(AVATARS[0]);
  const [error, setError] = useState("");
  const [limit, setLimit] = useState(false);
  const [pending, start] = useTransition();

  function submit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLimit(false);
    if (!name.trim()) {
      setError(t("nameRequired"));
      return;
    }
    start(async () => {
      const res = await addChildAction({ name: name.trim(), age, avatarEmoji: emoji });
      if (res.ok) {
        onClose();
        router.refresh();
      } else {
        setError(res.error ?? "Lỗi");
        setLimit(Boolean(res.limit));
      }
    });
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
      <form onSubmit={submit} className="app-card w-full max-w-sm p-6">
        <h3 className="text-lg font-bold text-on-surface mb-4">{t("addChild")}</h3>

        {/* avatar */}
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

        {error && (
          <div className="mb-3">
            <p className="text-sm text-error">{error}</p>
            {limit && (
              <Link
                href="/parent/pricing"
                className="text-sm text-primary font-semibold underline"
                onClick={onClose}
              >
                {t("upgradeFamily")} →
              </Link>
            )}
          </div>
        )}

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
            {pending ? t("saving") : t("addChild")}
          </button>
        </div>
      </form>
    </div>
  );
}
