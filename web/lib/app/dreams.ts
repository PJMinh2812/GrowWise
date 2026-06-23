import { createServerSupabase } from '@/lib/supabase-server'
import type { DreamItem, Badge } from '@/lib/types'

export async function getDreamItems(childId: string): Promise<DreamItem[]> {
  const supabase = await createServerSupabase()
  const { data } = await supabase
    .from('dream_items')
    .select('*')
    .eq('child_id', childId)
    .order('created_at', { ascending: false })
  return (data as DreamItem[]) ?? []
}

export async function getBadges(childId: string): Promise<Badge[]> {
  const supabase = await createServerSupabase()
  const { data } = await supabase
    .from('badges')
    .select('*')
    .eq('child_id', childId)
    .order('earned_at', { ascending: false })
  return (data as Badge[]) ?? []
}
