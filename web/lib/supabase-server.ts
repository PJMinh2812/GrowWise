import { cookies } from 'next/headers'
import { createServerClient } from '@supabase/ssr'

/**
 * Server-side Supabase client bound to the request cookie session.
 * Use inside Server Components, Route Handlers and Server Actions.
 * Read-only cookie access by default (setAll no-op) — pass a response
 * cookie setter in route handlers that need to refresh the session.
 */
export async function createServerSupabase() {
  const cookieStore = await cookies()
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => cookieStore.getAll(),
        setAll: (cookiesToSet) => {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options),
            )
          } catch {
            // Called from a Server Component — safe to ignore; the proxy
            // refreshes the session cookie on navigation.
          }
        },
      },
    },
  )
}
