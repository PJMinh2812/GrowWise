"use client";

import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";
import { useLang } from "./LangProvider";

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
      <span className="material-symbols-outlined text-xl">logout</span>
      <span className="hidden sm:inline">{t("logout")}</span>
    </button>
  );
}
