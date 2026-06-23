import { cookies } from 'next/headers'
import { createServerClient } from '@supabase/ssr'
import { createAdminClient } from '@/lib/supabase-admin'
import AdminShell from '@/components/AdminShell'

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  let role: 'admin' | 'manager' | 'staff' | null = null
  let email = ''

  try {
    const cookieStore = await cookies()
    const supabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        cookies: {
          getAll: () => cookieStore.getAll(),
          setAll: () => {},
        },
      }
    )

    const { data: { user } } = await supabase.auth.getUser()

    if (user) {
      email = user.email ?? ''
      const admin = createAdminClient()
      const { data: profile } = await admin
        .from('admin_profiles')
        .select('role')
        .eq('id', user.id)
        .single()

      const adminEmails = (process.env.ADMIN_EMAILS ?? '').split(',').map(e => e.trim())
      if (profile?.role === 'admin' || adminEmails.includes(email)) {
        role = 'admin'
      } else if (profile?.role === 'manager') {
        role = 'manager'
      } else if (profile?.role === 'staff') {
        role = 'staff'
      }
    }
  } catch {
    // unauthenticated — login page renders without sidebar
  }

  return (
    <AdminShell role={role} email={email}>
      {children}
    </AdminShell>
  )
}
