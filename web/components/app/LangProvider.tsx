"use client";

import { createContext, useContext, useState } from "react";
import { useRouter } from "next/navigation";
import { LANG_COOKIE, t as translate, type Lang, type TKey } from "@/lib/i18n";

interface LangCtx {
  lang: Lang;
  setLang: (l: Lang) => void;
  t: (key: TKey) => string;
}

const Ctx = createContext<LangCtx>({
  lang: "vi",
  setLang: () => {},
  t: (k) => translate("vi", k),
});

export function LangProvider({
  initialLang,
  children,
}: {
  initialLang: Lang;
  children: React.ReactNode;
}) {
  const router = useRouter();
  const [lang, setLangState] = useState<Lang>(initialLang);

  function setLang(l: Lang) {
    setLangState(l);
    document.cookie = `${LANG_COOKIE}=${l}; path=/; max-age=${60 * 60 * 24 * 365}; samesite=lax`;
    router.refresh(); // re-render server components with new language
  }

  return (
    <Ctx.Provider value={{ lang, setLang, t: (k) => translate(lang, k) }}>
      {children}
    </Ctx.Provider>
  );
}

export function useLang() {
  return useContext(Ctx);
}
