import { createServerClient } from '@supabase/ssr'
import { createAdminClient } from '@/lib/supabase-admin'
import type { NextRequest } from 'next/server'

export type AdminRole = 'admin' | 'manager' | 'staff'

/**
 * Resolve the current admin-panel user's effective role from the request
 * cookies. Returns null if not authenticated / no access / banned.
 * ADMIN_EMAILS are always treated as 'admin'.
 */
export async function getAdminRole(
  request: NextRequest,
): Promise<{ userId: string; role: AdminRole } | null> {
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies: { getAll: () => request.cookies.getAll(), setAll: () => {} } },
  )
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return null

  const admin = createAdminClient()
  const { data: profile } = await admin
    .from('admin_profiles')
    .select('role, access_granted, is_banned')
    .eq('id', user.id)
    .single()

  if (profile?.is_banned) return null

  const adminEmails = (process.env.ADMIN_EMAILS ?? '').split(',').map(e => e.trim())
  if (adminEmails.includes(user.email ?? '')) return { userId: user.id, role: 'admin' }
  if (profile?.access_granted) return { userId: user.id, role: (profile.role as AdminRole) ?? 'staff' }
  return null
}
