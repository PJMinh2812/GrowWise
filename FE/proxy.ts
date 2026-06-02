import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function proxy(request: NextRequest) {
  const response = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => request.cookies.getAll(),
        setAll: (cookiesToSet) => {
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  // getSession đọc từ cookie cục bộ — không cần network call
  const { data: { session } } = await supabase.auth.getSession()
  const isLoginPage = request.nextUrl.pathname === '/login'

  if (!session && !isLoginPage) {
    return NextResponse.redirect(new URL('/login', request.url))
  }
  if (session && isLoginPage) {
    return NextResponse.redirect(new URL('/lessons', request.url))
  }

  if (session) {
    try {
      const cachedRole = request.cookies.get('x-user-role')?.value

      if (cachedRole) {
        if (request.nextUrl.pathname.startsWith('/admin') && cachedRole !== 'admin') {
          return NextResponse.redirect(new URL('/lessons', request.url))
        }
        response.cookies.set('x-user-role', cachedRole, { httpOnly: false, sameSite: 'lax', path: '/' })
      } else {
        const { data: profile } = await supabase
          .from('admin_profiles')
          .select('role, is_banned, access_granted')
          .eq('id', session.user.id)
          .single()

        const adminEmails = (process.env.ADMIN_EMAILS ?? '').split(',').map(e => e.trim())
        const isAdminEmail = adminEmails.includes(session.user.email ?? '')

        const hasAccess = profile?.access_granted || isAdminEmail
        const role: string | null = hasAccess ? (profile?.role ?? 'admin') : null

        if (!role || profile?.is_banned) {
          await supabase.auth.signOut()
          return NextResponse.redirect(new URL(`/login?error=${profile?.is_banned ? 'banned' : 'unauthorized'}`, request.url))
        }

        if (request.nextUrl.pathname.startsWith('/admin') && role !== 'admin') {
          return NextResponse.redirect(new URL('/lessons', request.url))
        }

        response.cookies.set('x-user-role', role, { httpOnly: false, sameSite: 'lax', path: '/' })
      }
    } catch {
      // Nếu có lỗi (vd: DB không kết nối được), cho qua để tránh redirect loop
    }
  }

  return response
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
