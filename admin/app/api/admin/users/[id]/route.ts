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

// PATCH: cập nhật role hoặc is_banned
export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const adminId = await verifyAdmin(request)
  if (!adminId) return NextResponse.json({ error: 'Forbidden' }, { status: 403 })

  const { id } = await params
  if (id === adminId) return NextResponse.json({ error: 'Không thể tự sửa tài khoản của mình' }, { status: 400 })

  const body = await request.json()
  const admin = createAdminClient()

  // Upsert profile
  const { error } = await admin.from('admin_profiles').upsert({ id, ...body })
  if (error) return NextResponse.json({ error: error.message }, { status: 500 })

  return NextResponse.json({ ok: true })
}

// DELETE: xóa user
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const adminId = await verifyAdmin(request)
  if (!adminId) return NextResponse.json({ error: 'Forbidden' }, { status: 403 })

  const { id } = await params
  if (id === adminId) return NextResponse.json({ error: 'Không thể xóa tài khoản của mình' }, { status: 400 })

  const admin = createAdminClient()
  const { error } = await admin.auth.admin.deleteUser(id)
  if (error) return NextResponse.json({ error: error.message }, { status: 500 })

  return NextResponse.json({ ok: true })
}
