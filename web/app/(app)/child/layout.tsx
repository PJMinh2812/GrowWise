import Link from "next/link";
import AppShell, { type NavItem } from "@/components/app/AppShell";
import DashboardSky from "@/components/app/DashboardSky";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";
import { getSelectedChild } from "@/lib/app/children";

export default async function ChildLayout({ children }: { children: React.ReactNode }) {
  const [lang, child] = await Promise.all([getLang(), getSelectedChild()]);
  const nav: NavItem[] = [
    { href: "/child", label: t(lang, "navTasks"), icon: "assignment" },
    { href: "/child/jars", label: t(lang, "navJars"), icon: "account_balance_wallet" },
    { href: "/child/dreams", label: t(lang, "navDreams"), icon: "stars" },
    { href: "/child/learn", label: t(lang, "navLearn"), icon: "school" },
    { href: "/child/settings", label: t(lang, "navSettings"), icon: "settings" },
  ];

  const chatBtn = (
    <Link
      href="/child/chat"
      aria-label={t(lang, "navChat")}
      style={{
        display: "flex", alignItems: "center", justifyContent: "center",
        width: "36px", height: "36px", borderRadius: "50%",
        background: "var(--primary-fixed)", color: "var(--primary)",
        flexShrink: 0,
      }}
    >
      <span className="material-symbols-outlined" style={{ fontSize: "20px" }}>smart_toy</span>
    </Link>
  );

  return (
    <div className="theme-child">
      <AppShell
        brand="GrowWise Kids"
        brandSub={t(lang, "brandKids")}
        nav={nav}
        topRight={chatBtn}
        heroBgPath="/child"
        heroBg={<DashboardSky />}
        avatar={child ? { url: child.avatar_url ?? undefined, emoji: child.avatar_emoji, name: child.name } : undefined}
      >
        {children}
      </AppShell>
    </div>
  );
}
