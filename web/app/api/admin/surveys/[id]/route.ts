import { NextRequest, NextResponse } from 'next/server'
import { createAdminClient } from '@/lib/supabase-admin'
import { getAdminRole } from '@/lib/admin-auth'

export const runtime = 'nodejs'

// PATCH: publish / unpublish (and optional edits). Publishing requires admin|manager.
export async function PATCH(request: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  const auth = await getAdminRole(request)
  if (!auth) return NextResponse.json({ error: 'Forbidden' }, { status: 403 })

  const { id } = await params
  const body = (await request.json()) as {
    is_published?: boolean
    title?: string
    description?: string
    url?: string
    audience?: 'parent' | 'child' | 'all'
  }

  if (typeof body.is_published === 'boolean' && auth.role !== 'admin' && auth.role !== 'manager') {
    return NextResponse.json({ error: 'Chỉ Quản lý hoặc Admin được publish khảo sát' }, { status: 403 })
  }

  const patch: Record<string, unknown> = {}
  if (typeof body.is_published === 'boolean') {
    patch.is_published = body.is_published
    patch.published_at = body.is_published ? new Date().toISOString() : null
  }
  if (body.title !== undefined) patch.title = body.title
  if (body.description !== undefined) patch.description = body.description
  if (body.url !== undefined) patch.url = body.url
  if (body.audience !== undefined) patch.audience = body.audience
  if (Object.keys(patch).length === 0) {
    return NextResponse.json({ error: 'Không có thay đổi' }, { status: 400 })
  }

  const admin = createAdminClient()
  const { error } = await admin.from('surveys').update(patch).eq('id', id)
  if (error) return NextResponse.json({ error: error.message }, { status: 500 })

  return NextResponse.json({ ok: true })
}

// DELETE: remove a survey. Requires admin|manager.
export async function DELETE(request: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  const auth = await getAdminRole(request)
  if (!auth) return NextResponse.json({ error: 'Forbidden' }, { status: 403 })
  if (auth.role !== 'admin' && auth.role !== 'manager') {
    return NextResponse.json({ error: 'Chỉ Quản lý hoặc Admin được xoá' }, { status: 403 })
  }

  const { id } = await params
  const admin = createAdminClient()
  const { error } = await admin.from('surveys').delete().eq('id', id)
  if (error) return NextResponse.json({ error: error.message }, { status: 500 })

  return NextResponse.json({ ok: true })
}
