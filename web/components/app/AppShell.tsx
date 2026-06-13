"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import LanguageToggle from "./LanguageToggle";
import LogoutButton from "./LogoutButton";

export type NavItem = { href: string; label: string; icon: string };

export default function AppShell({
  brand,
  brandSub,
  nav,
  topRight,
  children,
}: {
  brand: string;
  brandSub?: string;
  nav: NavItem[];
  topRight?: React.ReactNode;
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const isActive = (href: string) =>
    pathname === href || (href !== "/parent" && href !== "/child" && pathname.startsWith(href));

  return (
    <div className="min-h-screen bg-background text-on-surface">
      {/* Sidebar (desktop) */}
      <nav className="hidden md:flex flex-col fixed left-0 top-0 h-screen w-[260px] bg-surface-container-low border-r border-outline-variant/30 z-40">
        <div className="p-6">
          <h1 className="text-2xl font-extrabold text-primary leading-tight">{brand}</h1>
          {brandSub && <p className="text-sm text-on-surface-variant mt-1">{brandSub}</p>}
        </div>
        <div className="flex flex-col gap-1 px-3 flex-1 overflow-y-auto">
          {nav.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 rounded-[14px] py-3 px-4 font-semibold transition ${
                isActive(item.href)
                  ? "bg-primary-container/30 text-primary"
                  : "text-on-surface-variant hover:bg-surface-container"
              }`}
            >
              <span className="text-sm">{item.label}</span>
            </Link>
          ))}
        </div>
        {/* Logout pinned at the bottom of the sidebar */}
        <div className="p-4 border-t border-outline-variant/30">
          <LogoutButton />
        </div>
      </nav>

      {/* Top bar */}
      <header className="fixed top-0 right-0 md:left-[260px] left-0 h-16 bg-surface/90 backdrop-blur border-b border-outline-variant/20 flex items-center justify-between px-4 md:px-8 z-30">
        <span className="md:hidden text-lg font-extrabold text-primary">{brand}</span>
        <div className="ml-auto flex items-center gap-3">
          <LanguageToggle />
          {topRight}
        </div>
      </header>

      {/* Content */}
      <main className="md:ml-[260px] pt-20 px-4 md:px-8 pb-24 md:pb-10 max-w-[1280px] mx-auto">
        {children}
      </main>

      {/* Bottom nav (mobile) */}
      <nav className="md:hidden fixed bottom-0 inset-x-0 h-16 bg-surface-container border-t border-outline-variant/20 flex justify-around items-center z-40">
        {nav.slice(0, 5).map((item) => (
          <Link
            key={item.href}
            href={item.href}
            className={`flex flex-col items-center justify-center flex-1 h-full ${
              isActive(item.href) ? "text-primary" : "text-on-surface-variant"
            }`}
          >
            <span className="text-xs font-semibold">{item.label}</span>
          </Link>
        ))}
      </nav>
    </div>
  );
}
