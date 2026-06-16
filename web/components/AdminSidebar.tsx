"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";

interface Props {
  role: "admin" | "manager" | "staff" | null;
}

const NAV = [
  { href: "/admin/dashboard", label: "Thống kê",    adminOnly: false },
  { href: "/admin/lessons",   label: "Bài học",     adminOnly: false },
  { href: "/admin/pricing",   label: "Định giá",    adminOnly: false },
  { href: "/admin/surveys",   label: "Khảo sát",    adminOnly: false },
  { href: "/admin/users",     label: "Người dùng",  adminOnly: true },
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
    <aside className="fixed left-0 top-0 h-full w-[200px] bg-surface-container-lowest border-r border-outline-variant flex flex-col py-5 overflow-y-auto z-30">
      {/* Logo */}
      <div className="px-4 mb-7">
        <h1 className="text-lg font-bold text-primary leading-tight">GrowWise</h1>
        <p className="text-xs text-on-surface-variant mt-0.5">Cổng quản trị</p>
      </div>

      {/* Nav items */}
      <nav className="flex-1 flex flex-col gap-0.5 px-2">
        {visible.map(({ href, label }) => {
          const active =
            pathname === href ||
            (href === "/admin/lessons" && pathname.startsWith("/admin/lessons")) ||
            (href !== "/admin/lessons" && pathname.startsWith(href + "/"));
          return (
            <Link
              key={href}
              href={href}
              className={`block px-3 py-2.5 text-base rounded-lg transition-all font-medium ${
                active
                  ? "bg-primary/10 text-primary font-semibold"
                  : "text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface"
              }`}
            >
              {label}
            </Link>
          );
        })}

        {/* Logout */}
        <div className="pt-5 mt-5 border-t border-outline-variant">
          <button
            onClick={handleLogout}
            className="block w-full text-left px-3 py-2.5 text-base font-medium text-error hover:bg-error-container/10 rounded-lg transition-colors"
          >
            Đăng xuất
          </button>
        </div>
      </nav>
    </aside>
  );
}
