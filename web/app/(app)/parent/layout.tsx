import Link from "next/link";
import AppShell, { type NavItem } from "@/components/app/AppShell";
import DashboardSky from "@/components/app/DashboardSky";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";
import { getActivePlan } from "@/lib/app/subscription";
import { getAppProfile } from "@/lib/app/auth";
import Icon from "@/components/Icon";

export default async function ParentLayout({ children }: { children: React.ReactNode }) {
  const [lang, plan, profile] = await Promise.all([getLang(), getActivePlan(), getAppProfile()]);
  const isFree = plan.name === "free";

  // Settings always lives in the header corner (far right). The bottom bar shows
  // Roadmap (manage tasks/roadmap) instead of a standalone "create task".
  const nav: NavItem[] = [
    { href: "/parent", label: t(lang, "navDashboard"), icon: "dashboard" },
    { href: "/parent/roadmap", label: t(lang, "navRoadmap"), icon: "route" },
    { href: "/parent/lessons", label: t(lang, "navLessons"), icon: "school" },
    { href: "/parent/memories", label: t(lang, "navMemories"), icon: "photo_library" },
    ...(isFree ? [{ href: "/parent/pricing", label: t(lang, "upgrade"), icon: "workspace_premium" }] : []),
  ];

  const iconBtn = (href: string, icon: string, label: string) => (
    <Link
      href={href}
      aria-label={label}
      style={{
        display: "flex", alignItems: "center", justifyContent: "center",
        width: "36px", height: "36px", borderRadius: "50%",
        background: "var(--primary-fixed)", color: "var(--primary)",
        flexShrink: 0,
      }}
    >
      <Icon name={icon} style={{ fontSize: "20px" }} />
    </Link>
  );

  // AI → Settings (Settings outermost right).
  const topRight = (
    <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
      {iconBtn("/parent/ai", "smart_toy", t(lang, "navAI"))}
      {iconBtn("/parent/settings", "settings", t(lang, "navSettings"))}
    </div>
  );

  return (
    <div className="theme-parent">
      <AppShell
        brand="GrowWise"
        brandSub={t(lang, "brandParent")}
        nav={nav}
        topRight={topRight}
        heroBgPath="/parent"
        heroBg={<DashboardSky />}
        avatar={{
          url: profile?.avatar_url ?? undefined,
          emoji: "👨‍👩‍👧",
          name: profile?.full_name ?? t(lang, "parent"),
        }}
      >
        {children}
      </AppShell>
    </div>
  );
}
