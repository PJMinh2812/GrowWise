import { cache } from 'react'
import type { User } from '@supabase/supabase-js'
import { createServerSupabase } from '@/lib/supabase-server'
import type { AppProfile } from '@/lib/types'

/**
 * The current authenticated user, memoized per server request via React
 * `cache()`. Many data helpers need the user in the same render; wrapping it
 * here collapses what used to be several `auth.getUser()` round-trips into one.
 */
export const getCurrentUser = cache(async (): Promise<User | null> => {
  const supabase = await createServerSupabase()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  return user
})

/** Current user's profile row (full_name, avatar_url, parent_pin_hash). */
export const getAppProfile = cache(async (): Promise<AppProfile | null> => {
  const user = await getCurrentUser()
  if (!user) return null
  const supabase = await createServerSupabase()
  const { data } = await supabase
    .from('profiles')
    .select('id, full_name, avatar_url, parent_pin_hash')
    .eq('id', user.id)
    .maybeSingle()
  return (data as AppProfile) ?? null
})
