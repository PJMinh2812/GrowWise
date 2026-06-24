import { createServerSupabase } from '@/lib/supabase-server'

export interface ChildTransaction {
  id: string
  child_id: string
  type: 'income' | 'expense'
  amount: number
  note: string | null
  jar: string | null
  created_by: string | null
  created_at: string
}

/** Thu/Chi history for a child, newest first. Returns [] if table missing. */
export async function getTransactions(childId: string, limit = 50): Promise<ChildTransaction[]> {
  if (!childId) return []
  const supabase = await createServerSupabase()
  const { data, error } = await supabase
    .from('child_transactions')
    .select('*')
    .eq('child_id', childId)
    .order('created_at', { ascending: false })
    .limit(limit)
  if (error) return []
  return (data as ChildTransaction[]) ?? []
}
