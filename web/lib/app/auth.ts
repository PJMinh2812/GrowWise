import { cache } from 'react'
import type { User } from '@supabase/supabase-js'
import { createServerSupabase } from '@/lib/supabase-server'

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
