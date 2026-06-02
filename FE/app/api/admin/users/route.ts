import { createServerClient } from '@supabase/ssr'
import { createAdminClient } from '@/lib/supabase-admin'
import { NextRequest, NextResponse } from 'next/server'

async function verifyAdmin(request: NextRequest): Promise<string | null> {
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => request.cookies.getAll(),
        setAll: () => {},
      },
    }
  )
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return null

  const admin = createAdminClient()
  const { data: profile } = await admin.from('admin_profiles').select('role').eq('id', user.id).single()

  const adminEmails = (process.env.ADMIN_EMAILS ?? '').split(',').map(e => e.trim())
  const isAdminEmail = adminEmails.includes(user.email ?? '')

  if (profile?.role === 'admin' || (!profile && isAdminEmail)) return user.id
  return null
}

export async function GET(request: NextRequest) {
  const adminId = await verifyAdmin(request)
  if (!adminId) return NextResponse.json({ error: 'Forbidden' }, { status: 403 })

  const admin = createAdminClient()
  const { data: { users }, error } = await admin.auth.admin.listUsers({ perPage: 1000 })
  if (error) return NextResponse.json({ error: error.message }, { status: 500 })

  const { data: profiles } = await admin.from('admin_profiles').select('*')

  const result = users.map(u => ({
    id: u.id,
    email: u.email ?? '',
    created_at: u.created_at,
    last_sign_in_at: u.last_sign_in_at,
    profile: profiles?.find(p => p.id === u.id) ?? null,
  }))

  return NextResponse.json(result)
}
