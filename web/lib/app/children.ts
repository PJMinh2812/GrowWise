import { cache } from 'react'
import { cookies } from 'next/headers'
import { createServerSupabase } from '@/lib/supabase-server'
import type { Child, Family } from '@/lib/types'

/**
 * Family owned by the currently logged-in parent (families.parent_id == uid).
 * Wrapped in React `cache()` so multiple callers in the same request (layout,
 * page, getSelectedChild → getMyChildren) only trigger one DB round-trip.
 */
export const getFamilyForUser = cache(async (): Promise<Family | null> => {
  const supabase = await createServerSupabase()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return null

  const { data } = await supabase
    .from('families')
    .select('*')
    .eq('parent_id', user.id)
    .maybeSingle()
  return (data as Family) ?? null
})

/** All children in a family, ordered by creation. */
export async function getChildren(familyId: string): Promise<Child[]> {
  const supabase = await createServerSupabase()
  const { data } = await supabase
    .from('children')
    .select('*')
    .eq('family_id', familyId)
    .order('created_at')
  return (data as Child[]) ?? []
}

/** Children of the logged-in parent's family (convenience). */
export async function getMyChildren(): Promise<Child[]> {
  const family = await getFamilyForUser()
  if (!family) return []
  return getChildren(family.id)
}

export async function getChild(childId: string): Promise<Child | null> {
  const supabase = await createServerSupabase()
  const { data } = await supabase
    .from('children')
    .select('*')
    .eq('id', childId)
    .maybeSingle()
  return (data as Child) ?? null
}

/**
 * The child currently in use (set via `gw_child_id` cookie on the role
 * screen). Falls back to the parent's first child.
 */
export async function getSelectedChild(): Promise<Child | null> {
  const cookieStore = await cookies()
  const id = cookieStore.get('gw_child_id')?.value
  if (id) {
    const child = await getChild(id)
    if (child) return child
  }
  const children = await getMyChildren()
  return children[0] ?? null
}
