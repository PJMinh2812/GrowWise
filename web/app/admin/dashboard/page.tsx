'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import * as XLSX from 'xlsx'

interface Stats {
  totalUsers: number
  newUsersThisMonth: number
  monthlyRevenue: number
  activeSubs: number
  trialSubs: number
  canceledSubs: number
  planSummary: { name: string; display_name: string; subscribers: number; free: number }[]
  salesByPlan: { plan: string; count: number; revenue: number }[]
  revenueByMonth: { month: string; revenue: number; count: number }[]
  newUsersByMonth: { month: string; count: number }[]
  revenueByWeek: { label: string; range: string; revenue: number; count: number }[]
  newUsersByWeek: { label: string; range: string; count: number }[]
  statusByMonth: { month: string; completed: number; failed: number; cancelled: number }[]
  totalRevenue: number
  txnStatusBreakdown: { completed: number; pending: number; failed: number; cancelled: number }
  recentTxns: {
    order_id: string
    plan_name: string
    amount: number
    status: string
    provider: string
    billing_interval: string
    created_at: string
    email: string
  }[]
}

function formatVND(n: number) {
  return n.toLocaleString('vi-VN') + '₫'
}

function formatDate(iso: string) {
  return new Date(iso).toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric' })
}

function StatusBadge({ status }: { status: string }) {
  const styles: Record<string, string> = {
    completed: 'bg-secondary-container text-on-secondary-container',
    pending:   'bg-tertiary-fixed/40 text-tertiary',
    failed:    'bg-error-container text-on-error-container',
    cancelled: 'bg-surface-container-high text-on-surface-variant',
  }
  const labels: Record<string, string> = {
    completed: 'Thành công',
    pending:   'Đang chờ',
    failed:    'Thất bại',
    cancelled: 'Đã hủy',
  }
  return (
    <span className={`px-2 py-0.5 rounded-full text-xs font-semibold ${styles[status] ?? 'bg-surface-container-high text-on-surface-variant'}`}>
      {labels[status] ?? status}
    </span>
  )
}

function ProviderBadge({ provider }: { provider: string }) {
  const styles: Record<string, string> = {
    momo:  'bg-pink-100 text-pink-700',
    payos: 'bg-blue-100 text-blue-700',
    vnpay: 'bg-indigo-100 text-indigo-700',
  }
  return (
    <span className={`px-2 py-0.5 rounded text-xs font-medium ${styles[provider] ?? 'bg-surface-container-high text-on-surface-variant'}`}>
      {provider?.toUpperCase()}
    </span>
  )
}

function formatCompactVND(n: number) {
  if (n >= 1_000_000) return (n / 1_000_000).toFixed(n % 1_000_000 === 0 ? 0 : 1) + 'tr'
  if (n >= 1_000) return Math.round(n / 1_000) + 'k'
  return String(n)
}

const PLAN_LABELS: Record<string, string> = { free: 'Cơ Bản', premium: 'Nâng Cao', family: 'Gia Đình' }

/** Reusable vertical bar chart over labelled buckets (months or weeks). */
function BarsChart({
  items,
  color,
  format,
  emptyText,
}: {
  items: { label: string; value: number; tip?: string }[]
  color: string
  format: (n: number) => string
  emptyText: string
}) {
  const max = Math.max(1, ...items.map(d => d.value))
  const hasData = items.some(d => d.value > 0)
  return (
    <div>
      <div className="flex items-end justify-between gap-3 h-48">
        {items.map((d, i) => {
          const pct = Math.round((d.value / max) * 100)
          return (
            <div key={i} className="flex-1 flex flex-col items-center justify-end h-full gap-2">
              <span className="text-[11px] font-semibold text-on-surface-variant">
                {d.value > 0 ? format(d.value) : ''}
              </span>
              <div
                className={`w-full max-w-[44px] rounded-t-md transition-all ${color}`}
                style={{ height: `${Math.max(pct, d.value > 0 ? 4 : 0)}%` }}
                title={d.tip ?? `${d.label}: ${format(d.value)}`}
              />
              <span className="text-[11px] text-on-surface-variant whitespace-nowrap">{d.label}</span>
            </div>
          )
        })}
      </div>
      {!hasData && <p className="text-center text-sm text-on-surface-variant mt-4">{emptyText}</p>}
    </div>
  )
}

/** Reusable line chart over labelled buckets (months or weeks). */
function LineChart({
  items,
  format,
  emptyText,
}: {
  items: { label: string; value: number; tip?: string }[]
  format: (n: number) => string
  emptyText: string
}) {
  const W = 560
  const H = 200
  const padX = 28
  const padTop = 24
  const padBottom = 28
  const max = Math.max(1, ...items.map(d => d.value))
  const hasData = items.some(d => d.value > 0)
  const n = items.length
  const x = (i: number) => (n <= 1 ? W / 2 : padX + (i * (W - padX * 2)) / (n - 1))
  const y = (v: number) => padTop + (1 - v / max) * (H - padTop - padBottom)
  const pts = items.map((d, i) => `${x(i)},${y(d.value)}`).join(' ')
  return (
    <div>
      <svg viewBox={`0 0 ${W} ${H}`} className="w-full h-48" preserveAspectRatio="none">
        {/* baseline */}
        <line x1={padX} y1={H - padBottom} x2={W - padX} y2={H - padBottom} stroke="currentColor" className="text-outline-variant" strokeWidth={1} />
        {hasData && (
          <polyline points={pts} fill="none" className="text-blue-500" stroke="currentColor" strokeWidth={2.5} strokeLinejoin="round" strokeLinecap="round" />
        )}
        {items.map((d, i) => (
          <g key={i}>
            {hasData && <circle cx={x(i)} cy={y(d.value)} r={4} className="text-blue-500 fill-current" />}
            {d.value > 0 && (
              <text x={x(i)} y={y(d.value) - 9} textAnchor="middle" className="fill-on-surface-variant" fontSize={11} fontWeight={600}>
                {format(d.value)}
              </text>
            )}
            <text x={x(i)} y={H - padBottom + 16} textAnchor="middle" className="fill-on-surface-variant" fontSize={11}>
              {d.label}
            </text>
            <title>{d.tip ?? `${d.label}: ${format(d.value)}`}</title>
          </g>
        ))}
      </svg>
      {!hasData && <p className="text-center text-sm text-on-surface-variant mt-2">{emptyText}</p>}
    </div>
  )
}

/** Pie (conic-gradient) of the 3 transaction statuses + legend. */
function StatusPie({ data }: { data: { completed: number; failed: number; cancelled: number } }) {
  const parts = [
    { label: 'Thành công', value: data.completed, color: '#16a34a' },
    { label: 'Thất bại', value: data.failed, color: '#dc2626' },
    { label: 'Đã hủy', value: data.cancelled, color: '#9ca3af' },
  ]
  const total = parts.reduce((s, p) => s + p.value, 0)
  if (total === 0) {
    return <p className="text-center text-sm text-on-surface-variant py-10">Chưa có giao dịch trong tháng này</p>
  }
  let acc = 0
  const stops = parts
    .map(p => {
      const start = (acc / total) * 100
      acc += p.value
      const end = (acc / total) * 100
      return `${p.color} ${start}% ${end}%`
    })
    .join(', ')
  return (
    <div className="flex flex-col sm:flex-row items-center gap-6">
      <div className="w-40 h-40 rounded-full shrink-0" style={{ background: `conic-gradient(${stops})` }} />
      <div className="space-y-2 w-full">
        {parts.map(p => (
          <div key={p.label} className="flex items-center gap-2 text-sm">
            <span className="w-3 h-3 rounded-sm" style={{ background: p.color }} />
            <span className="text-on-surface flex-1">{p.label}</span>
            <span className="font-semibold text-on-surface">{p.value}</span>
            <span className="text-on-surface-variant w-12 text-right">{Math.round((p.value / total) * 100)}%</span>
          </div>
        ))}
        <div className="pt-2 mt-1 border-t border-outline-variant flex justify-between text-sm">
          <span className="text-on-surface-variant">Tổng đơn</span>
          <span className="font-bold text-on-surface">{total}</span>
        </div>
      </div>
    </div>
  )
}

/** Small Tháng/Tuần segmented toggle. */
function ModeToggle({ mode, onChange }: { mode: 'month' | 'week'; onChange: (m: 'month' | 'week') => void }) {
  return (
    <div className="inline-flex rounded-lg border border-outline-variant overflow-hidden text-xs font-semibold">
      {(['month', 'week'] as const).map(m => (
        <button
          key={m}
          onClick={() => onChange(m)}
          className={`px-3 py-1 transition-colors ${
            mode === m ? 'bg-primary text-on-primary' : 'bg-surface-container-lowest text-on-surface-variant hover:bg-surface-container'
          }`}
        >
          {m === 'month' ? 'Tháng' : 'Tuần'}
        </button>
      ))}
    </div>
  )
}

const STATUS_META: { key: keyof Stats['txnStatusBreakdown']; label: string; color: string }[] = [
  { key: 'completed', label: 'Thành công', color: 'bg-secondary' },
  { key: 'pending',   label: 'Đang chờ',   color: 'bg-tertiary' },
  { key: 'failed',    label: 'Thất bại',   color: 'bg-error' },
  { key: 'cancelled', label: 'Đã hủy',     color: 'bg-outline' },
]

function StatusChart({ data }: { data: Stats['txnStatusBreakdown'] }) {
  const total = STATUS_META.reduce((s, m) => s + (data[m.key] ?? 0), 0)
  const max = Math.max(1, ...STATUS_META.map(m => data[m.key] ?? 0))
  const settled = (data.completed ?? 0) + (data.failed ?? 0) + (data.cancelled ?? 0)
  const conversion = settled > 0 ? Math.round(((data.completed ?? 0) / settled) * 100) : 0
  if (total === 0) {
    return <p className="text-center text-sm text-on-surface-variant py-8">Chưa có giao dịch nào</p>
  }
  return (
    <div>
      <div className="space-y-3">
        {STATUS_META.map(m => {
          const n = data[m.key] ?? 0
          return (
            <div key={m.key}>
              <div className="flex justify-between items-baseline mb-1">
                <span className="text-sm text-on-surface">{m.label}</span>
                <span className="text-xs font-semibold text-on-surface">{n}</span>
              </div>
              <div className="h-2.5 w-full rounded-full bg-surface-container overflow-hidden">
                <div className={`h-full rounded-full ${m.color}`} style={{ width: `${Math.max(Math.round((n / max) * 100), n > 0 ? 6 : 0)}%` }} />
              </div>
            </div>
          )
        })}
      </div>
      <div className="mt-5 pt-4 border-t border-outline-variant flex justify-between items-center">
        <span className="text-sm text-on-surface-variant">Tỷ lệ chuyển đổi thanh toán</span>
        <span className="text-lg font-bold text-secondary">{conversion}%</span>
      </div>
    </div>
  )
}

function PlanSalesChart({ data }: { data: Stats['salesByPlan'] }) {
  if (!data.length) {
    return <p className="text-center text-sm text-on-surface-variant py-8">Chưa có đơn mua nào</p>
  }
  const max = Math.max(1, ...data.map(d => d.count))
  const colors = ['bg-primary', 'bg-secondary', 'bg-tertiary', 'bg-outline']
  return (
    <div className="space-y-4">
      {data.map((d, i) => (
        <div key={d.plan}>
          <div className="flex justify-between items-baseline mb-1">
            <span className="text-sm font-medium text-on-surface">{PLAN_LABELS[d.plan] ?? d.plan}</span>
            <span className="text-xs text-on-surface-variant">
              {d.count} đơn · <span className="font-semibold text-on-surface">{formatVND(d.revenue)}</span>
            </span>
          </div>
          <div className="h-3 w-full rounded-full bg-surface-container overflow-hidden">
            <div
              className={`h-full rounded-full ${colors[i % colors.length]}`}
              style={{ width: `${Math.max(Math.round((d.count / max) * 100), 6)}%` }}
            />
          </div>
        </div>
      ))}
    </div>
  )
}

const STATUS_LABEL: Record<string, string> = {
  completed: 'Thành công',
  pending: 'Đang chờ',
  failed: 'Thất bại',
  cancelled: 'Đã hủy',
}

/** Export a real multi-sheet .xlsx workbook (numbers stay numeric for Excel). */
function exportXLSX(stats: Stats) {
  const todayStr = new Date().toLocaleDateString('vi-VN').replace(/\//g, '-')
  const settled = stats.txnStatusBreakdown.completed + stats.txnStatusBreakdown.failed + stats.txnStatusBreakdown.cancelled
  const conversion = settled > 0 ? Math.round((stats.txnStatusBreakdown.completed / settled) * 100) : 0

  const wb = XLSX.utils.book_new()

  // Sheet: Tổng quan
  const overview = [
    ['Chỉ số', 'Giá trị'],
    ['Tổng người dùng', stats.totalUsers],
    ['Người dùng mới tháng này', stats.newUsersThisMonth],
    ['Đang dùng Premium', stats.activeSubs],
    ['Dùng thử', stats.trialSubs],
    ['Đã hủy (gói)', stats.canceledSubs],
    ['Doanh thu tháng này (VNĐ)', stats.monthlyRevenue],
    ['Tổng doanh thu (VNĐ)', stats.totalRevenue],
    ['Tỷ lệ chuyển đổi thanh toán (%)', conversion],
  ]
  const wsOverview = XLSX.utils.aoa_to_sheet(overview)
  wsOverview['!cols'] = [{ wch: 32 }, { wch: 18 }]
  XLSX.utils.book_append_sheet(wb, wsOverview, 'Tổng quan')

  // Sheet: Doanh thu theo tháng
  const wsRevenue = XLSX.utils.aoa_to_sheet([
    ['Tháng', 'Doanh thu (VNĐ)', 'Số đơn'],
    ...stats.revenueByMonth.map(m => [m.month, m.revenue, m.count]),
  ])
  wsRevenue['!cols'] = [{ wch: 12 }, { wch: 18 }, { wch: 10 }]
  XLSX.utils.book_append_sheet(wb, wsRevenue, 'Doanh thu theo tháng')

  // Sheet: Người dùng mới theo tháng
  const wsUsers = XLSX.utils.aoa_to_sheet([
    ['Tháng', 'Người dùng mới'],
    ...stats.newUsersByMonth.map(m => [m.month, m.count]),
  ])
  wsUsers['!cols'] = [{ wch: 12 }, { wch: 16 }]
  XLSX.utils.book_append_sheet(wb, wsUsers, 'Người dùng mới')

  // Sheet: Theo gói
  const wsPlan = XLSX.utils.aoa_to_sheet([
    ['Gói', 'Số đơn đã mua', 'Doanh thu (VNĐ)'],
    ...stats.salesByPlan.map(p => [PLAN_LABELS[p.plan] ?? p.plan, p.count, p.revenue]),
  ])
  wsPlan['!cols'] = [{ wch: 16 }, { wch: 14 }, { wch: 18 }]
  XLSX.utils.book_append_sheet(wb, wsPlan, 'Theo gói')

  // Sheet: Trạng thái giao dịch
  const wsStatus = XLSX.utils.aoa_to_sheet([
    ['Trạng thái', 'Số đơn'],
    ['Thành công', stats.txnStatusBreakdown.completed],
    ['Đang chờ', stats.txnStatusBreakdown.pending],
    ['Thất bại', stats.txnStatusBreakdown.failed],
    ['Đã hủy', stats.txnStatusBreakdown.cancelled],
  ])
  wsStatus['!cols'] = [{ wch: 16 }, { wch: 10 }]
  XLSX.utils.book_append_sheet(wb, wsStatus, 'Trạng thái giao dịch')

  // Sheet: Giao dịch gần đây
  const wsTxns = XLSX.utils.aoa_to_sheet([
    ['Mã đơn', 'Email', 'Gói', 'Số tiền (VNĐ)', 'Phương thức', 'Trạng thái', 'Ngày tạo'],
    ...stats.recentTxns.map(t => [
      t.order_id,
      t.email,
      t.plan_name,
      t.amount,
      t.provider?.toUpperCase() ?? '',
      STATUS_LABEL[t.status] ?? t.status,
      new Date(t.created_at).toLocaleDateString('vi-VN'),
    ]),
  ])
  wsTxns['!cols'] = [{ wch: 16 }, { wch: 26 }, { wch: 12 }, { wch: 16 }, { wch: 12 }, { wch: 12 }, { wch: 12 }]
  XLSX.utils.book_append_sheet(wb, wsTxns, 'Giao dịch gần đây')

  XLSX.writeFile(wb, `growwise-baocao-${todayStr}.xlsx`)
}

export default function DashboardPage() {
  const router = useRouter()
  const [stats, setStats] = useState<Stats | null>(null)
  const [loading, setLoading] = useState(true)
  const [revenueMode, setRevenueMode] = useState<'month' | 'week'>('month')
  const [usersMode, setUsersMode] = useState<'month' | 'week'>('month')
  const [pieMonth, setPieMonth] = useState<string>('')

  useEffect(() => {
    fetch('/api/admin/stats')
      .then(res => {
        if (res.status === 403) { router.replace('/admin/lessons'); return null }
        return res.json()
      })
      .then(data => { if (data) setStats(data) })
      .finally(() => setLoading(false))
  }, [router])

  const today = new Date().toLocaleDateString('vi-VN', {
    weekday: 'long', day: 'numeric', month: 'long', year: 'numeric',
  })

  if (loading) {
    return (
      <div className="p-6">
        <div className="h-8 w-48 bg-surface-container rounded animate-pulse mb-2" />
        <div className="h-4 w-32 bg-surface-container rounded animate-pulse mb-8" />
        <div className="grid grid-cols-4 gap-6">
          {[0,1,2,3].map(i => (
            <div key={i} className="bg-surface-container-lowest rounded-xl border border-outline-variant p-6 h-28 animate-pulse" />
          ))}
        </div>
      </div>
    )
  }

  if (!stats) return null

  // Real month-over-month revenue change (last two monthly buckets)
  const rev = stats.revenueByMonth
  const thisMonthRev = rev[rev.length - 1]?.revenue ?? 0
  const lastMonthRev = rev[rev.length - 2]?.revenue ?? 0
  const revDeltaPct =
    lastMonthRev > 0
      ? Math.round(((thisMonthRev - lastMonthRev) / lastMonthRev) * 100)
      : thisMonthRev > 0
        ? 100
        : 0

  // Current month label for weekly-mode subtitle (e.g. "06/2026")
  const curMonthLabel = (() => {
    const last = stats.revenueByMonth[stats.revenueByMonth.length - 1]?.month
    if (!last) return ''
    const [y, m] = last.split('-')
    return `${m}/${y}`
  })()
  const monthOpt = (key: string) => {
    const [y, m] = key.split('-')
    return `Tháng ${m}/${y}`
  }
  const pieMonthKey = pieMonth || stats.statusByMonth[stats.statusByMonth.length - 1]?.month || ''
  const pieData = stats.statusByMonth.find(s => s.month === pieMonthKey) ?? { completed: 0, failed: 0, cancelled: 0 }

  return (
    <div className="p-6 max-w-[1440px]">
      {/* Page header */}
      <div className="mb-8 flex justify-between items-end">
        <div>
          <h2 className="text-3xl font-bold text-on-surface">Tổng quan</h2>
          <p className="text-sm text-on-surface-variant mt-1 capitalize">{today}</p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => exportXLSX(stats)}
            className="flex items-center gap-2 px-4 py-2 border border-outline-variant rounded-lg text-sm text-on-surface-variant hover:bg-surface-container transition-colors"
          >
            ⬇️ Xuất báo cáo
          </button>
        </div>
      </div>

      {/* Stat cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {/* Revenue */}
        <div className="group bg-surface-container-lowest p-6 rounded-xl border border-outline-variant flex flex-col gap-3 hover:-translate-y-0.5 hover:shadow-md transition-all cursor-default">
          <div className="flex justify-between items-start">
            <div className="p-2 bg-secondary/10 rounded-lg text-xl">
              💰
            </div>
            <span className={`text-xs font-semibold px-2 py-0.5 rounded ${revDeltaPct >= 0 ? 'text-secondary bg-secondary/10' : 'text-error bg-error/10'}`}>
              {revDeltaPct >= 0 ? '+' : ''}{revDeltaPct}% so với tháng trước
            </span>
          </div>
          <div>
            <p className="text-sm text-on-surface-variant">Doanh thu tháng này</p>
            <h3 className="text-2xl font-bold text-secondary mt-1">{formatVND(stats.monthlyRevenue)}</h3>
            <p className="text-xs text-on-surface-variant mt-1">Tổng tất cả: {formatVND(stats.totalRevenue)}</p>
          </div>
        </div>

        {/* Total users */}
        <div className="group bg-surface-container-lowest p-6 rounded-xl border border-outline-variant flex flex-col gap-3 hover:-translate-y-0.5 hover:shadow-md transition-all cursor-default">
          <div className="flex justify-between items-start">
            <div className="p-2 bg-blue-100 rounded-lg text-xl">
              👥
            </div>
            {stats.newUsersThisMonth > 0 && (
              <span className="text-xs font-semibold text-blue-600 bg-blue-100 px-2 py-0.5 rounded">+{stats.newUsersThisMonth} mới</span>
            )}
          </div>
          <div>
            <p className="text-sm text-on-surface-variant">Tổng người dùng</p>
            <h3 className="text-2xl font-bold text-blue-600 mt-1">{stats.totalUsers.toLocaleString()}</h3>
          </div>
        </div>

        {/* Active premium */}
        <div className="group bg-surface-container-lowest p-6 rounded-xl border border-outline-variant flex flex-col gap-3 hover:-translate-y-0.5 hover:shadow-md transition-all cursor-default">
          <div className="flex justify-between items-start">
            <div className="p-2 bg-primary/10 rounded-lg text-xl">
              ⭐
            </div>
            <span className="text-xs font-semibold text-primary bg-primary/10 px-2 py-0.5 rounded">
              {stats.totalUsers > 0 ? Math.round((stats.activeSubs / stats.totalUsers) * 100) : 0}% tỷ lệ
            </span>
          </div>
          <div>
            <p className="text-sm text-on-surface-variant">Đang dùng Premium</p>
            <h3 className="text-2xl font-bold text-primary mt-1">{stats.activeSubs}</h3>
          </div>
        </div>

        {/* New users */}
        <div className="group bg-surface-container-lowest p-6 rounded-xl border border-outline-variant flex flex-col gap-3 hover:-translate-y-0.5 hover:shadow-md transition-all cursor-default">
          <div className="flex justify-between items-start">
            <div className="p-2 bg-orange-100 rounded-lg text-xl">
              🆕
            </div>
          </div>
          <div>
            <p className="text-sm text-on-surface-variant">Người dùng mới tháng này</p>
            <h3 className="text-2xl font-bold text-orange-600 mt-1">{stats.newUsersThisMonth}</h3>
          </div>
        </div>
      </div>

      {/* Charts row 1 */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 mb-6">
        {/* Revenue by month/week */}
        <section className="lg:col-span-7 bg-surface-container-lowest rounded-xl border border-outline-variant p-6">
          <div className="flex justify-between items-start mb-1">
            <h4 className="text-base font-semibold text-on-surface">
              Doanh thu {revenueMode === 'month' ? '6 tháng gần đây' : `các tuần tháng ${curMonthLabel}`}
            </h4>
            <ModeToggle mode={revenueMode} onChange={setRevenueMode} />
          </div>
          <p className="text-xs text-on-surface-variant mb-5">Tổng từ các giao dịch thành công</p>
          <BarsChart
            items={
              revenueMode === 'month'
                ? stats.revenueByMonth.map(d => ({
                    label: `T${Number(d.month.split('-')[1])}`,
                    value: d.revenue,
                    tip: `Tháng ${d.month.split('-')[1]}: ${formatVND(d.revenue)} · ${d.count} đơn`,
                  }))
                : stats.revenueByWeek.map(d => ({
                    label: d.range,
                    value: d.revenue,
                    tip: `${d.label} (${d.range}): ${formatVND(d.revenue)} · ${d.count} đơn`,
                  }))
            }
            color="bg-secondary/80 hover:bg-secondary"
            format={formatCompactVND}
            emptyText={revenueMode === 'month' ? 'Chưa có doanh thu trong 6 tháng gần đây' : 'Chưa có doanh thu trong tháng này'}
          />
        </section>

        {/* Buyers by plan */}
        <section className="lg:col-span-5 bg-surface-container-lowest rounded-xl border border-outline-variant p-6">
          <h4 className="text-base font-semibold text-on-surface mb-1">Người mua theo gói</h4>
          <p className="text-xs text-on-surface-variant mb-5">Số đơn thành công &amp; doanh thu mỗi gói</p>
          <PlanSalesChart data={stats.salesByPlan} />
        </section>
      </div>

      {/* Charts row 2 */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 mb-8">
        {/* New users by month/week */}
        <section className="lg:col-span-7 bg-surface-container-lowest rounded-xl border border-outline-variant p-6">
          <div className="flex justify-between items-start mb-1">
            <h4 className="text-base font-semibold text-on-surface">
              Người dùng mới {usersMode === 'month' ? '(6 tháng)' : `(các tuần tháng ${curMonthLabel})`}
            </h4>
            <ModeToggle mode={usersMode} onChange={setUsersMode} />
          </div>
          <p className="text-xs text-on-surface-variant mb-5">Số tài khoản đăng ký</p>
          <LineChart
            items={
              usersMode === 'month'
                ? stats.newUsersByMonth.map(d => ({
                    label: `T${Number(d.month.split('-')[1])}`,
                    value: d.count,
                    tip: `Tháng ${d.month.split('-')[1]}: ${d.count} người dùng mới`,
                  }))
                : stats.newUsersByWeek.map(d => ({
                    label: d.range,
                    value: d.count,
                    tip: `${d.label} (${d.range}): ${d.count} người dùng mới`,
                  }))
            }
            format={(n) => String(n)}
            emptyText={usersMode === 'month' ? 'Chưa có người dùng mới trong 6 tháng gần đây' : 'Chưa có người dùng mới trong tháng này'}
          />
        </section>

        {/* Transaction status breakdown */}
        <section className="lg:col-span-5 bg-surface-container-lowest rounded-xl border border-outline-variant p-6">
          <h4 className="text-base font-semibold text-on-surface mb-1">Trạng thái giao dịch</h4>
          <p className="text-xs text-on-surface-variant mb-5">Toàn bộ đơn hàng theo trạng thái</p>
          <StatusChart data={stats.txnStatusBreakdown} />
        </section>
      </div>

      {/* Transaction status pie (per selected month) */}
      <div className="mb-6">
        <section className="bg-surface-container-lowest rounded-xl border border-outline-variant p-6">
          <div className="flex flex-wrap justify-between items-center gap-3 mb-5">
            <div>
              <h4 className="text-base font-semibold text-on-surface">Tỷ lệ trạng thái giao dịch</h4>
              <p className="text-xs text-on-surface-variant mt-1">Thành công · Thất bại · Đã hủy theo tháng đã chọn</p>
            </div>
            <select
              value={pieMonthKey}
              onChange={e => setPieMonth(e.target.value)}
              className="border border-outline-variant rounded-lg px-3 py-2 text-sm text-on-surface bg-surface-container-lowest outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
            >
              {stats.statusByMonth.map(s => (
                <option key={s.month} value={s.month}>{monthOpt(s.month)}</option>
              ))}
            </select>
          </div>
          <StatusPie data={pieData} />
        </section>
      </div>

      {/* Recent transactions (full width) */}
      <div className="mb-8">
        <section className="bg-surface-container-lowest rounded-xl border border-outline-variant overflow-hidden flex flex-col">
          <div className="px-6 py-4 border-b border-outline-variant flex justify-between items-center">
            <h4 className="text-base font-semibold text-on-surface">Giao dịch gần đây</h4>
            <div className="flex items-center gap-2">
              <a href="/admin/pricing" className="text-sm text-primary hover:underline">Tất cả →</a>
            </div>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="bg-surface-container-low">
                <tr>
                  <th className="px-4 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Mã đơn</th>
                  <th className="px-4 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Gói</th>
                  <th className="px-4 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Số tiền</th>
                  <th className="px-4 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Trạng thái</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-outline-variant">
                {stats.recentTxns.length === 0 && (
                  <tr>
                    <td colSpan={4} className="px-4 py-8 text-center text-on-surface-variant">Chưa có giao dịch nào</td>
                  </tr>
                )}
                {stats.recentTxns.map((txn, i) => (
                  <tr key={i} className="hover:bg-surface-container-low transition-colors">
                    <td className="px-4 py-3 font-mono text-xs text-on-surface-variant">#{txn.order_id?.slice(-6).toUpperCase() ?? '—'}</td>
                    <td className="px-4 py-3 text-sm capitalize text-on-surface">{txn.plan_name}</td>
                    <td className="px-4 py-3 text-sm font-semibold text-on-surface">{formatVND(txn.amount)}</td>
                    <td className="px-4 py-3"><StatusBadge status={txn.status} /></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      </div>

    </div>
  )
}
