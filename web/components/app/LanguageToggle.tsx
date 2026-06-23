"use client";

import { useLang } from "./LangProvider";

export default function LanguageToggle() {
  const { lang, setLang } = useLang();
  return (
    <div className="inline-flex items-center rounded-full border border-outline-variant overflow-hidden text-xs font-bold">
      <button
        onClick={() => setLang("vi")}
        className={`px-2.5 py-1 ${lang === "vi" ? "bg-primary text-on-primary" : "text-on-surface-variant"}`}
        aria-pressed={lang === "vi"}
      >
        VI
      </button>
      <button
        onClick={() => setLang("en")}
        className={`px-2.5 py-1 ${lang === "en" ? "bg-primary text-on-primary" : "text-on-surface-variant"}`}
        aria-pressed={lang === "en"}
      >
        EN
      </button>
    </div>
  );
}
