import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'
import { createAdminClient } from '@/lib/supabase-admin'

export async function middleware(request: NextRequest) {
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

  const { data: { user } } = await supabase.auth.getUser()
  const isLoginPage = request.nextUrl.pathname === '/login'

  if (!user && !isLoginPage) {
    return NextResponse.redirect(new URL('/login', request.url))
  }
  if (user && isLoginPage) {
    return NextResponse.redirect(new URL('/lessons', request.url))
  }

  if (user) {
    const admin = createAdminClient()
    const { data: profile } = await admin
      .from('admin_profiles')
      .select('role, is_banned')
      .eq('id', user.id)
      .single()

    const adminEmails = (process.env.ADMIN_EMAILS ?? '').split(',').map(e => e.trim())
    const isAdminEmail = adminEmails.includes(user.email ?? '')

    // Bootstrap: tự tạo profile cho admin đầu tiên nếu chưa có
    if (!profile && isAdminEmail) {
      await admin.from('admin_profiles').insert({ id: user.id, email: user.email, role: 'admin' })
    }

    const role: string | null = profile?.role ?? (isAdminEmail ? 'admin' : null)

    if (!role) {
      await supabase.auth.signOut()
      return NextResponse.redirect(new URL('/login?error=unauthorized', request.url))
    }

    if (profile?.is_banned) {
      await supabase.auth.signOut()
      return NextResponse.redirect(new URL('/login?error=banned', request.url))
    }

    // Chỉ admin mới vào được /admin/*
    if (request.nextUrl.pathname.startsWith('/admin') && role !== 'admin') {
      return NextResponse.redirect(new URL('/lessons', request.url))
    }

    response.cookies.set('x-user-role', role, { httpOnly: false, sameSite: 'lax', path: '/' })
  }

  return response
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
