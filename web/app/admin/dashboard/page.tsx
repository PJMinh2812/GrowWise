'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'

interface Stats {
  totalUsers: number
  newUsersThisMonth: number
  monthlyRevenue: number
  activeSubs: number
  trialSubs: number
  canceledSubs: number
  planSummary: { display_name: string; monthly: number; yearly: number; free: number }[]
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

function exportCSV(stats: Stats) {
  const todayStr = new Date().toLocaleDateString('vi-VN').replace(/\//g, '-')

  // Sheet 1: tổng quan
  const summary = [
    ['Chỉ số', 'Giá trị'],
    ['Tổng người dùng', stats.totalUsers],
    ['Người dùng mới tháng này', stats.newUsersThisMonth],
    ['Đang dùng Premium', stats.activeSubs],
    ['Dùng thử', stats.trialSubs],
    ['Đã hủy', stats.canceledSubs],
    ['Doanh thu tháng này (VNĐ)', stats.monthlyRevenue],
    [],
    ['Gói', 'Hàng tháng', 'Hàng năm', 'Tổng'],
    ...stats.planSummary.map(p => [p.display_name, p.monthly, p.yearly, p.monthly + p.yearly]),
    [],
    ['Mã đơn', 'Gói', 'Số tiền (VNĐ)', 'Phương thức', 'Chu kỳ', 'Trạng thái', 'Ngày tạo'],
    ...stats.recentTxns.map(t => [
      t.order_id,
      t.plan_name,
      t.amount,
      t.provider?.toUpperCase(),
      t.billing_interval === 'yearly' ? 'Hàng năm' : 'Hàng tháng',
      t.status === 'completed' ? 'Thành công' : t.status === 'pending' ? 'Đang chờ' : 'Thất bại',
      new Date(t.created_at).toLocaleDateString('vi-VN'),
    ]),
  ]

  const csv = summary.map(row => row.map(v => `"${v ?? ''}"`).join(',')).join('\n')
  const blob = new Blob(['﻿' + csv], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `growwise-baocao-${todayStr}.csv`
  a.click()
  URL.revokeObjectURL(url)
}

export default function DashboardPage() {
  const router = useRouter()
  const [stats, setStats] = useState<Stats | null>(null)
  const [loading, setLoading] = useState(true)

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
            onClick={() => exportCSV(stats)}
            className="flex items-center gap-2 px-4 py-2 border border-outline-variant rounded-lg text-sm text-on-surface-variant hover:bg-surface-container transition-colors"
          >
            ⬇️ Xuất báo cáo
          </button>
          <button className="flex items-center gap-2 px-4 py-2 bg-primary text-on-primary rounded-lg text-sm font-semibold hover:opacity-90 active:scale-95 transition-all">
            + Tạo chiến dịch
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
            <span className="text-xs font-semibold text-secondary bg-secondary/10 px-2 py-0.5 rounded">+12.5%</span>
          </div>
          <div>
            <p className="text-sm text-on-surface-variant">Doanh thu tháng này</p>
            <h3 className="text-2xl font-bold text-secondary mt-1">{formatVND(stats.monthlyRevenue)}</h3>
          </div>
        </div>

        {/* Total users */}
        <div className="group bg-surface-container-lowest p-6 rounded-xl border border-outline-variant flex flex-col gap-3 hover:-translate-y-0.5 hover:shadow-md transition-all cursor-default">
          <div className="flex justify-between items-start">
            <div className="p-2 bg-blue-100 rounded-lg text-xl">
              👥
            </div>
            <span className="text-xs font-semibold text-blue-600 bg-blue-100 px-2 py-0.5 rounded">+5.2%</span>
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

      {/* Tables row */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 mb-8">
        {/* Plan summary */}
        <section className="lg:col-span-5 bg-surface-container-lowest rounded-xl border border-outline-variant overflow-hidden flex flex-col">
          <div className="px-6 py-4 border-b border-outline-variant flex justify-between items-center">
            <h4 className="text-base font-semibold text-on-surface">Gói đăng ký</h4>
            <a href="/admin/pricing" className="text-sm text-primary hover:underline">Chi tiết →</a>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="bg-surface-container-low">
                <tr>
                  <th className="px-6 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Gói</th>
                  <th className="px-6 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Người đăng ký</th>
                  <th className="px-6 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider text-right">Doanh thu</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-outline-variant">
                {stats.planSummary.map((plan, i) => {
                  const total = plan.monthly + plan.yearly
                  const colors = ['bg-primary', 'bg-secondary', 'bg-outline']
                  return (
                    <tr key={i} className="hover:bg-surface-container-low transition-colors">
                      <td className="px-6 py-3">
                        <div className="flex items-center gap-2">
                          <span className={`w-2 h-2 rounded-full ${colors[i] ?? 'bg-outline'}`} />
                          <span className="text-sm text-on-surface">{plan.display_name}</span>
                        </div>
                      </td>
                      <td className="px-6 py-3 text-sm text-on-surface font-medium">{total}</td>
                      <td className="px-6 py-3 text-sm text-on-surface font-semibold text-right">
                        {plan.free > 0 ? '0₫' : '—'}
                      </td>
                    </tr>
                  )
                })}
                {stats.trialSubs > 0 && (
                  <tr className="hover:bg-surface-container-low transition-colors">
                    <td className="px-6 py-3">
                      <div className="flex items-center gap-2">
                        <span className="w-2 h-2 rounded-full bg-blue-400" />
                        <span className="text-sm text-on-surface">Dùng thử</span>
                      </div>
                    </td>
                    <td className="px-6 py-3 text-sm font-medium" colSpan={2}>{stats.trialSubs}</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </section>

        {/* Recent transactions */}
        <section className="lg:col-span-7 bg-surface-container-lowest rounded-xl border border-outline-variant overflow-hidden flex flex-col">
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

      {/* Admin insight banner */}
      <div className="relative overflow-hidden rounded-2xl bg-primary-container p-10 text-on-primary-container">
        <div className="relative z-10">
          <h3 className="text-2xl font-bold mb-2">Gợi ý quản trị hôm nay</h3>
          <p className="text-base opacity-90 max-w-2xl">
            Tỷ lệ chuyển đổi sang Premium tăng 12% so với tuần trước. Hãy xem xét việc khởi động chiến dịch
            &ldquo;Mùa hè tiết kiệm&rdquo; để đẩy mạnh người dùng Basic đăng ký gói năm.
          </p>
          <button className="mt-6 px-6 py-2.5 bg-surface text-primary rounded-xl text-sm font-semibold hover:shadow-lg transition-all active:scale-95">
            Xem phân tích sâu
          </button>
        </div>
        <div className="absolute right-[-20px] top-[-20px] opacity-20 pointer-events-none text-[200px] leading-none select-none">
          💡
        </div>
      </div>
    </div>
  )
}
