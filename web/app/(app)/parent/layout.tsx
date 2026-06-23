import Link from "next/link";
import AppShell, { type NavItem } from "@/components/app/AppShell";
import DashboardSky from "@/components/app/DashboardSky";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";
import { getActivePlan } from "@/lib/app/subscription";
import { getAppProfile } from "@/lib/app/auth";

export default async function ParentLayout({ children }: { children: React.ReactNode }) {
  const [lang, plan, profile] = await Promise.all([getLang(), getActivePlan(), getAppProfile()]);
  const isFree = plan.name === "free";

  // The bottom bar shows at most 5 items. On the free plan we surface "Upgrade"
  // there and move Settings to a gear in the header corner (like the kid view's
  // chat button) so it isn't pushed off the bar.
  const nav: NavItem[] = [
    { href: "/parent", label: t(lang, "navDashboard"), icon: "dashboard" },
    { href: "/parent/tasks/new", label: t(lang, "navCreateTask"), icon: "add_task" },
    { href: "/parent/lessons", label: t(lang, "navLessons"), icon: "school" },
    { href: "/parent/memories", label: t(lang, "navMemories"), icon: "photo_library" },
    isFree
      ? { href: "/parent/pricing", label: t(lang, "upgrade"), icon: "workspace_premium" }
      : { href: "/parent/settings", label: t(lang, "navSettings"), icon: "settings" },
  ];

  const settingsBtn = isFree ? (
    <Link
      href="/parent/settings"
      aria-label={t(lang, "navSettings")}
      style={{
        display: "flex", alignItems: "center", justifyContent: "center",
        width: "36px", height: "36px", borderRadius: "50%",
        background: "var(--primary-fixed)", color: "var(--primary)",
        flexShrink: 0,
      }}
    >
      <span className="material-symbols-outlined" style={{ fontSize: "20px" }}>settings</span>
    </Link>
  ) : undefined;

  return (
    <div className="theme-parent">
      <AppShell
        brand="GrowWise"
        brandSub={t(lang, "brandParent")}
        nav={nav}
        topRight={settingsBtn}
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
