import { type NextRequest, NextResponse } from 'next/server'

export function middleware(request: NextRequest) {
  const { pathname, searchParams, origin } = request.nextUrl

  // If OAuth code lands on any page other than /auth/callback, forward it there
  const code = searchParams.get('code')
  if (code && pathname !== '/auth/callback') {
    const url = new URL('/auth/callback', origin)
    url.searchParams.set('code', code)
    url.searchParams.set('next', '/role')
    return NextResponse.redirect(url)
  }

  return NextResponse.next()
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
