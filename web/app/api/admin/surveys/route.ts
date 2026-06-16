import { NextRequest, NextResponse } from 'next/server'
import { createAdminClient } from '@/lib/supabase-admin'
import { getAdminRole } from '@/lib/admin-auth'

export const runtime = 'nodejs'

// List all surveys (newest first) + current user's role (so UI knows publish rights)
export async function GET(request: NextRequest) {
  const auth = await getAdminRole(request)
  if (!auth) return NextResponse.json({ error: 'Forbidden' }, { status: 403 })

  const admin = createAdminClient()
  const { data, error } = await admin
    .from('surveys')
    .select('*')
    .order('created_at', { ascending: false })
  if (error) return NextResponse.json({ error: error.message }, { status: 500 })

  return NextResponse.json({ surveys: data ?? [], role: auth.role })
}

// Create a survey (draft). Any admin-panel role can create.
export async function POST(request: NextRequest) {
  const auth = await getAdminRole(request)
  if (!auth) return NextResponse.json({ error: 'Forbidden' }, { status: 403 })

  const { title, description, url, audience, min_age, max_age } = (await request.json()) as {
    title?: string
    description?: string
    url?: string
    audience?: 'parent' | 'child' | 'all'
    min_age?: number | null
    max_age?: number | null
  }
  if (!title?.trim() || !url?.trim()) {
    return NextResponse.json({ error: 'Thiếu tiêu đề hoặc link' }, { status: 400 })
  }

  const admin = createAdminClient()
  const { error } = await admin.from('surveys').insert({
    title: title.trim(),
    description: description?.trim() || null,
    url: url.trim(),
    audience: audience ?? 'all',
    min_age: min_age ?? null,
    max_age: max_age ?? null,
    is_published: false,
    created_by: auth.userId,
  })
  if (error) return NextResponse.json({ error: error.message }, { status: 500 })

  return NextResponse.json({ ok: true })
}
