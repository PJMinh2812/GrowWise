import AppShell, { type NavItem } from "@/components/app/AppShell";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";
import { getActivePlan } from "@/lib/app/subscription";

export default async function ParentLayout({ children }: { children: React.ReactNode }) {
  const lang = await getLang();
  const plan = await getActivePlan();
  const nav: NavItem[] = [
    { href: "/parent", label: t(lang, "navDashboard"), icon: "dashboard" },
    { href: "/parent/tasks/new", label: t(lang, "navCreateTask"), icon: "add_task" },
    { href: "/parent/lessons", label: t(lang, "navLessons"), icon: "school" },
    { href: "/parent/memories", label: t(lang, "navMemories"), icon: "photo_library" },
    // Upgrade entry only for free accounts
    ...(plan.name === "free"
      ? [{ href: "/parent/pricing", label: t(lang, "upgrade"), icon: "workspace_premium" }]
      : []),
    { href: "/parent/settings", label: t(lang, "navSettings"), icon: "settings" },
  ];
  return (
    <div className="theme-parent">
      <AppShell brand="GrowWise" brandSub={t(lang, "brandParent")} nav={nav}>
        {children}
      </AppShell>
    </div>
  );
}
