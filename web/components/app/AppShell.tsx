"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import LanguageToggle from "./LanguageToggle";

export type NavItem = { href: string; label: string; icon: string };

export type AvatarInfo = {
  emoji?: string;
  url?: string;
  name: string;
};

export default function AppShell({
  brand,
  brandSub,
  nav,
  topRight,
  avatar,
  heroBg,
  heroBgPath,
  children,
}: {
  brand: string;
  brandSub?: string;
  nav: NavItem[];
  topRight?: React.ReactNode;
  avatar?: AvatarInfo;
  /** Decorative backdrop shown only on `heroBgPath` (e.g. the dashboard). */
  heroBg?: React.ReactNode;
  heroBgPath?: string;
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const showHeroBg = Boolean(heroBg) && pathname === heroBgPath;
  const isActive = (href: string) =>
    pathname === href || (href !== "/parent" && href !== "/child" && pathname.startsWith(href));

  const navItems = nav.slice(0, 5);

  return (
    <div className="gw-screen text-on-surface">
      {showHeroBg && <div className="gw-herobg">{heroBg}</div>}
      <header className="gw-top">
        <div className="brand min-w-0">
          {avatar ? (
            <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
              {avatar.url ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={avatar.url}
                  alt={avatar.name}
                  style={{ width: "32px", height: "32px", borderRadius: "50%", objectFit: "cover", flexShrink: 0 }}
                />
              ) : (
                <span
                  aria-hidden
                  style={{
                    width: "32px", height: "32px", borderRadius: "50%",
                    background: "var(--primary-fixed)",
                    display: "flex", alignItems: "center", justifyContent: "center",
                    fontSize: "18px", lineHeight: "1", flexShrink: 0,
                  }}
                >
                  {avatar.emoji ?? "👤"}
                </span>
              )}
              <b className="truncate" style={{ maxWidth: "120px" }}>{avatar.name}</b>
            </div>
          ) : (
            <>
              <b className="truncate">{brand}</b>
              {brandSub && (
                <span className="text-xs font-semibold text-on-surface-variant hidden sm:inline">
                  {brandSub}
                </span>
              )}
            </>
          )}
        </div>
        <div className="flex items-center gap-2 shrink-0">
          {topRight}
          <LanguageToggle />
        </div>
      </header>

      <main className="gw-scroll">
        <div key={pathname} className="gw-page">{children}</div>
      </main>

      <nav className="gw-nav">
        {navItems.map((item) => {
          const active = isActive(item.href);
          return (
            <Link key={item.href} href={item.href} className={active ? "active" : undefined}>
              {active ? (
                <span className="bubble">
                  <span className="material-symbols-outlined">{item.icon}</span>
                </span>
              ) : (
                <span className="material-symbols-outlined">{item.icon}</span>
              )}
              <span>{item.label}</span>
            </Link>
          );
        })}
      </nav>
    </div>
  );
}
