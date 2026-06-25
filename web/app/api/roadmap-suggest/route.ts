import { NextRequest, NextResponse } from 'next/server'
import { createServerSupabase } from '@/lib/supabase-server'
import { SUGGEST_POOL, withSchedule } from '@/lib/app/roadmap-bands'

export const runtime = 'nodejs'

/**
 * Suggest extra daily habit tasks for "Gợi ý thêm nhiệm vụ" — curated pool minus
 * what the child already has, normalized with a schedule.
 */
export async function POST(req: NextRequest) {
  const supabase = await createServerSupabase()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return NextResponse.json({ error: 'unauthorized' }, { status: 401 })

  const { childId } = (await req.json()) as { childId: string }
  if (!childId) return NextResponse.json({ tasks: [] })

  const { data: existing } = await supabase
    .from('tasks')
    .select('title')
    .eq('child_id', childId)
    .eq('is_template', true)
  const taken = new Set((existing ?? []).map((t) => String(t.title).trim().toLowerCase()))

  const tasks = withSchedule(
    SUGGEST_POOL.filter((t) => !taken.has(t.title.trim().toLowerCase())).slice(0, 6),
  )
  return NextResponse.json({ tasks })
}
