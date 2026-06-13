"use client";

import Link from "next/link";
import { useLang } from "./LangProvider";

export default function SwitchRoleButton() {
  const { t } = useLang();
  return (
    <Link
      href="/role"
      className="flex items-center gap-1 text-sm font-semibold text-on-surface-variant hover:text-primary transition"
    >
      <span className="material-symbols-outlined text-xl">swap_horiz</span>
      <span className="hidden sm:inline">{t("switchRole")}</span>
    </Link>
  );
}
