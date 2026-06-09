'use client'

import { usePathname } from 'next/navigation'
import AdminSidebar from './AdminSidebar'

interface Props {
  children: React.ReactNode
  role: 'admin' | 'staff' | null
  email: string
}

const NO_SIDEBAR = ['/admin/login']

const NO_TOPBAR_PATTERN = /^\/admin\/lessons\/.+/

export default function AdminShell({ children, role, email }: Props) {
  const pathname = usePathname()
  const showSidebar = !NO_SIDEBAR.some(p => pathname.startsWith(p))
  const showTopBar = showSidebar && !NO_TOPBAR_PATTERN.test(pathname)

  const avatarLetter = email ? email[0].toUpperCase() : 'A'

  if (!showSidebar) return <>{children}</>

  return (
    <div className="min-h-screen bg-[#F9FAFB]">
      <AdminSidebar role={role} />
      <main className="ml-[280px] min-h-screen flex flex-col">
        {showTopBar && (
          <header className="h-16 px-6 bg-surface border-b border-outline-variant flex justify-between items-center sticky top-0 z-40">
            {/* Search */}
            <div className="flex items-center gap-3 bg-surface-container rounded-lg px-4 py-2 w-80">
              <span className="material-symbols-outlined text-on-surface-variant text-[20px]">search</span>
              <input
                className="bg-transparent border-none outline-none text-sm text-on-surface placeholder:text-on-surface-variant w-full"
                placeholder="Tìm kiếm hệ thống..."
                type="text"
              />
            </div>

            {/* Right actions */}
            <div className="flex items-center gap-4">
              <button className="material-symbols-outlined text-on-surface-variant hover:text-primary transition-colors text-[22px]">
                notifications
              </button>
              <button className="material-symbols-outlined text-on-surface-variant hover:text-primary transition-colors text-[22px]">
                settings
              </button>
              <div className="h-6 w-px bg-outline-variant" />
              <div className="flex items-center gap-2 cursor-pointer">
                <div className="w-8 h-8 rounded-full bg-primary/20 flex items-center justify-center text-primary font-bold text-sm">
                  {avatarLetter}
                </div>
                <span className="text-sm font-medium text-on-surface">Admin</span>
              </div>
            </div>
          </header>
        )}
        {children}
      </main>
    </div>
  )
}
