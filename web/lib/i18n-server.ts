import { cookies } from 'next/headers'
import { LANG_COOKIE, type Lang } from '@/lib/i18n'

/** Read the language from the cookie (server-side). Defaults to Vietnamese. */
export async function getLang(): Promise<Lang> {
  const store = await cookies()
  return (store.get(LANG_COOKIE)?.value as Lang) === 'en' ? 'en' : 'vi'
}
