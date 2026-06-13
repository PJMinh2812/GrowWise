import AppShell, { type NavItem } from "@/components/app/AppShell";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export default async function ChildLayout({ children }: { children: React.ReactNode }) {
  const lang = await getLang();
  const nav: NavItem[] = [
    { href: "/child", label: t(lang, "navTasks"), icon: "assignment" },
    { href: "/child/jars", label: t(lang, "navJars"), icon: "account_balance_wallet" },
    { href: "/child/dreams", label: t(lang, "navDreams"), icon: "stars" },
    { href: "/child/learn", label: t(lang, "navLearn"), icon: "school" },
    { href: "/child/achievements", label: t(lang, "navAchievements"), icon: "emoji_events" },
    { href: "/child/chat", label: t(lang, "navChat"), icon: "smart_toy" },
  ];
  return (
    <div className="theme-child">
      <AppShell brand="GrowWise Kids" brandSub={t(lang, "brandKids")} nav={nav}>
        {children}
      </AppShell>
    </div>
  );
}
