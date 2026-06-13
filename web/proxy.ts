import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'
import { createAdminClient } from '@/lib/supabase-admin'

async function resolveRole(
  userId: string,
  userEmail: string,
): Promise<{ role: string | null; isBanned: boolean }> {
  const adminEmails = (process.env.ADMIN_EMAILS ?? '')
    .split(',')
    .map((e) => e.trim())
    .filter(Boolean)
  const isAdminEmail = adminEmails.includes(userEmail)

  try {
    const admin = createAdminClient()
    const { data: profile, error } = await admin
      .from('admin_profiles')
      .select('role, is_banned, access_granted')
      .eq('id', userId)
      .maybeSingle()

    if (error) throw error

    // Bootstrap: tự tạo profile cho admin đầu tiên nếu chưa có
    if (!profile && isAdminEmail) {
      await admin
        .from('admin_profiles')
        .insert({ id: userId, email: userEmail, role: 'admin', access_granted: true })
      return { role: 'admin', isBanned: false }
    }

    if (profile?.is_banned) return { role: null, isBanned: true }

    const hasAccess = profile?.access_granted || isAdminEmail
    return {
      role: hasAccess ? (profile?.role ?? 'admin') : null,
      isBanned: false,
    }
  } catch {
    // Fallback khi SUPABASE_SERVICE_ROLE_KEY chưa set hoặc table chưa tạo:
    // chỉ dùng ADMIN_EMAILS để xác định quyền
    return { role: isAdminEmail ? 'admin' : null, isBanned: false }
  }
}

export async function proxy(request: NextRequest) {
  const pathname = request.nextUrl.pathname
  
  // Allow landing page to be accessed without authentication
  if (pathname === '/') {
    return NextResponse.next({ request })
  }

  // Skip auth check if Supabase env vars are not configured
  if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY) {
    return NextResponse.next({ request })
  }

  const response = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => request.cookies.getAll(),
        setAll: (cookiesToSet) => {
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options),
          )
        },
      },
    },
  )

  const {
    data: { user },
  } = await supabase.auth.getUser()

  const isLoginPage = pathname === '/admin/login'
  const isAdminRoute = pathname.startsWith('/admin')

  // Chưa đăng nhập → chỉ được vào trang admin/login
  if (!user) {
    if (isAdminRoute && !isLoginPage) {
      return NextResponse.redirect(new URL('/admin/login', request.url))
    }
    return response
  }

  // Đã đăng nhập → kiểm tra quyền TRƯỚC KHI quyết định redirect
  const { role, isBanned } = await resolveRole(user.id, user.email ?? '')

  // Không có quyền hoặc bị ban → cho ở lại login (không redirect ra /admin/lessons)
  if (!role || isBanned) {
    if (isLoginPage) {
      return response
    }
    const errorParam = isBanned ? 'banned' : 'unauthorized'
    return NextResponse.redirect(
      new URL(`/admin/login?error=${errorParam}`, request.url),
    )
  }

  // Có quyền + đang ở trang login → vào dashboard
  if (isLoginPage) {
    return NextResponse.redirect(new URL('/admin/lessons', request.url))
  }

  // Phân quyền theo route: chỉ admin mới vào /admin/users
  if (pathname.startsWith('/admin/users') && role !== 'admin') {
    return NextResponse.redirect(new URL('/admin/lessons', request.url))
  }

  response.cookies.set('x-user-role', role, {
    httpOnly: false,
    sameSite: 'lax',
    path: '/',
  })
  return response
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|auth/callback).*)'],
}
