import { createServerSupabase } from '@/lib/supabase-server'
import type { Memory } from '@/lib/types'

export async function getMemories(familyId: string, childId?: string): Promise<Memory[]> {
  const supabase = await createServerSupabase()
  let q = supabase.from('memories').select('*').eq('family_id', familyId)
  if (childId) q = q.eq('child_id', childId)
  const { data } = await q.order('created_at', { ascending: false })
  return (data as Memory[]) ?? []
}
