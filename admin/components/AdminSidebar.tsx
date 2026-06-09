"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";

interface Props {
  role: "admin" | "staff" | null;
}

const NAV = [
  { href: "/admin/dashboard", icon: "analytics",  label: "Thống kê",    adminOnly: true },
  { href: "/admin/lessons",   icon: "menu_book",  label: "Bài học",     adminOnly: false },
  { href: "/admin/pricing",   icon: "payments",   label: "Pricing",     adminOnly: false },
  { href: "/admin/users",     icon: "group",      label: "Người dùng",  adminOnly: true },
];

export default function AdminSidebar({ role }: Props) {
  const pathname = usePathname();
  const router = useRouter();

  async function handleLogout() {
    await createClient().auth.signOut();
    router.push("/admin/login");
  }

  const visible = NAV.filter((n) => !n.adminOnly || role === "admin");

  return (
    <aside className="fixed left-0 top-0 h-full w-[280px] bg-surface-container-lowest border-r border-outline-variant flex flex-col py-6 overflow-y-auto z-30">
      {/* Logo */}
      <div className="px-6 mb-8">
        <h1 className="text-2xl font-bold text-primary">GrowWise Admin</h1>
        <p className="text-sm text-on-surface-variant mt-0.5">Management Portal</p>
      </div>

      {/* Nav items */}
      <nav className="flex-1 flex flex-col gap-1 px-2">
        {visible.map(({ href, icon, label }) => {
          const active =
            pathname === href ||
            (href === "/admin/lessons" && pathname.startsWith("/admin/lessons")) ||
            (href !== "/admin/lessons" && pathname.startsWith(href + "/"));
          return (
            <Link
              key={href}
              href={href}
              className={`flex items-center gap-4 px-4 py-2.5 text-sm transition-all ${
                active
                  ? "bg-primary/10 text-primary border-l-4 border-primary rounded-r-lg font-semibold"
                  : "text-on-surface-variant hover:bg-surface-container-high rounded-lg border-l-4 border-transparent"
              }`}
            >
              <span className="material-symbols-outlined text-[20px]">{icon}</span>
              {label}
            </Link>
          );
        })}

        {/* Logout */}
        <div className="pt-6 mt-6 border-t border-outline-variant mx-1">
          <button
            onClick={handleLogout}
            className="flex items-center gap-4 px-4 py-2.5 text-sm text-error hover:bg-error-container/10 w-full rounded-lg transition-colors"
          >
            <span className="material-symbols-outlined text-[20px]">logout</span>
            Đăng xuất
          </button>
        </div>
      </nav>
    </aside>
  );
}
