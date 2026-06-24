/**
 * The UTC instant of 00:00 today in Vietnam time (UTC+7, no DST). Used to scope
 * task submissions to "today" so roadmap tasks reset each day.
 */
export function startOfTodayVN(): Date {
  const now = new Date()
  const vn = new Date(now.getTime() + 7 * 3600 * 1000)
  vn.setUTCHours(0, 0, 0, 0)
  return new Date(vn.getTime() - 7 * 3600 * 1000)
}
