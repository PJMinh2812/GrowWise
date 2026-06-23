'use client'

import { usePathname } from 'next/navigation'
import AdminSidebar from './AdminSidebar'

interface Props {
  children: React.ReactNode
  role: 'admin' | 'manager' | 'staff' | null
  email: string
}

const NO_SIDEBAR = ['/admin/login']

export default function AdminShell({ children, role }: Props) {
  const pathname = usePathname()
  const showSidebar = !NO_SIDEBAR.some(p => pathname.startsWith(p))

  if (!showSidebar) return <>{children}</>

  return (
    <div className="min-h-screen bg-[#F9FAFB]">
      <AdminSidebar role={role} />
      <main className="ml-[200px] min-h-screen">
        {children}
      </main>
    </div>
  )
}
