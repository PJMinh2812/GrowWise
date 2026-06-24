"use client";

import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";
import { useLang } from "./LangProvider";
import Icon from "@/components/Icon";

export default function LogoutButton() {
  const router = useRouter();
  const { t } = useLang();
  async function logout() {
    await createClient().auth.signOut();
    router.push("/login");
    router.refresh();
  }
  return (
    <button
      onClick={logout}
      className="flex items-center gap-1 text-sm font-semibold text-on-surface-variant hover:text-error transition"
    >
      <Icon name="logout" className="text-xl" />
      <span>{t("logout")}</span>
    </button>
  );
}
