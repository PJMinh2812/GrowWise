"use client";

import Link from "next/link";
import { useLang } from "./LangProvider";
import Icon from "@/components/Icon";

export default function SwitchRoleButton() {
  const { t } = useLang();
  return (
    <Link
      href="/role"
      className="flex items-center gap-1 text-sm font-semibold text-on-surface-variant hover:text-primary transition"
    >
      <Icon name="swap_horiz" className="text-xl" />
      <span>{t("switchRole")}</span>
    </Link>
  );
}
