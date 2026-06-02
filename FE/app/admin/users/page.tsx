'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase'

interface UserRow {
  id: string
  email: string
  created_at: string
  last_sign_in_at: string | null
  profile: { role: 'admin' | 'staff'; is_banned: boolean } | null
}

export default function AdminUsersPage() {
  const router = useRouter()
  const [users, setUsers] = useState<UserRow[]>([])
  const [loading, setLoading] = useState(true)
  const [busy, setBusy] = useState<string | null>(null)
  const [inviteEmail, setInviteEmail] = useState('')
  const [inviteRole, setInviteRole] = useState<'staff' | 'admin'>('staff')
  const [inviting, setInviting] = useState(false)
  const [inviteError, setInviteError] = useState('')
  const [inviteSuccess, setInviteSuccess] = useState('')

  useEffect(() => { fetchUsers() }, [])

  async function fetchUsers() {
    setLoading(true)
    const res = await fetch('/api/admin/users')
    if (!res.ok) { router.push('/lessons'); return }
    setUsers(await res.json())
    setLoading(false)
  }

  async function handleLogout() {
    const supabase = createClient()
    await supabase.auth.signOut()
    router.push('/login')
  }

  async function updateUser(id: string, patch: object) {
    setBusy(id)
    const res = await fetch(`/api/admin/users/${id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(patch),
    })
    if (!res.ok) {
      const { error } = await res.json()
      alert(error)
    }
    await fetchUsers()
    setBusy(null)
  }

  async function grantAccess(u: UserRow) {
    await updateUser(u.id, { email: u.email, role: 'staff', is_banned: false })
  }

  async function handleInvite(e: React.FormEvent) {
    e.preventDefault()
    setInviting(true)
    setInviteError('')
    setInviteSuccess('')
    const res = await fetch('/api/admin/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: inviteEmail, role: inviteRole }),
    })
    const json = await res.json()
    if (!res.ok) {
      setInviteError(json.error ?? 'Có lỗi xảy ra')
    } else {
      setInviteSuccess(`Đã gửi lời mời đến ${inviteEmail}`)
      setInviteEmail('')
      await fetchUsers()
    }
    setInviting(false)
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <span className="text-2xl">🌱</span>
          <h1 className="text-lg font-bold text-gray-900">GrowWise Admin</h1>
        </div>
        <div className="flex items-center gap-4">
          <Link href="/lessons" className="text-sm text-gray-500 hover:text-gray-700">Bài học</Link>
          <span className="text-sm font-semibold text-violet-700">Người dùng</span>
          <button onClick={handleLogout} className="text-sm text-gray-400 hover:text-gray-600">Đăng xuất</button>
        </div>
      </header>

      <main className="max-w-5xl mx-auto px-6 py-8 space-y-6">
        {/* Invite form */}
        <div className="bg-white border border-gray-200 rounded-xl p-6">
          <h2 className="font-semibold text-gray-900 mb-4">Mời thành viên mới</h2>
          <form onSubmit={handleInvite} className="flex gap-3 items-end">
            <div className="flex-1">
              <label className="block text-xs font-medium text-gray-600 mb-1">Email</label>
              <input
                type="email"
                required
                value={inviteEmail}
                onChange={e => setInviteEmail(e.target.value)}
                placeholder="staff@example.com"
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500"
              />
            </div>
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">Vai trò</label>
              <select
                value={inviteRole}
                onChange={e => setInviteRole(e.target.value as 'staff' | 'admin')}
                className="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500"
              >
                <option value="staff">Staff</option>
                <option value="admin">Admin</option>
              </select>
            </div>
            <button
              type="submit"
              disabled={inviting}
              className="bg-violet-600 text-white px-5 py-2 rounded-lg text-sm font-semibold hover:bg-violet-700 disabled:opacity-50 transition"
            >
              {inviting ? 'Đang gửi...' : 'Gửi lời mời'}
            </button>
          </form>
          {inviteError && <p className="mt-2 text-xs text-red-600">{inviteError}</p>}
          {inviteSuccess && <p className="mt-2 text-xs text-green-600">{inviteSuccess}</p>}
        </div>

        {/* User list */}
        <div>
          <p className="text-sm text-gray-500 mb-3">{users.length} tài khoản</p>
          {loading ? (
            <div className="text-center py-12 text-gray-400">Đang tải...</div>
          ) : (
            <div className="bg-white border border-gray-200 rounded-xl overflow-hidden">
              <table className="w-full text-sm">
                <thead className="bg-gray-50 border-b border-gray-200">
                  <tr>
                    <th className="text-left px-4 py-3 font-semibold text-gray-700">Email</th>
                    <th className="text-left px-4 py-3 font-semibold text-gray-700">Vai trò</th>
                    <th className="text-left px-4 py-3 font-semibold text-gray-700">Trạng thái</th>
                    <th className="text-left px-4 py-3 font-semibold text-gray-700">Đăng nhập gần nhất</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {users.map(u => (
                    <tr key={u.id} className={u.profile?.is_banned ? 'bg-red-50' : ''}>
                      <td className="px-4 py-3 text-gray-900 font-medium">{u.email}</td>
                      <td className="px-4 py-3">
                        {u.profile ? (
                          <select
                            value={u.profile.role}
                            disabled={busy === u.id}
                            onChange={e => updateUser(u.id, { email: u.email, role: e.target.value, is_banned: u.profile!.is_banned })}
                            className="border border-gray-200 rounded-lg px-2 py-1 text-xs focus:outline-none focus:ring-2 focus:ring-violet-500 disabled:opacity-50"
                          >
                            <option value="staff">Staff</option>
                            <option value="admin">Admin</option>
                          </select>
                        ) : (
                          <button
                            onClick={() => grantAccess(u)}
                            disabled={busy === u.id}
                            className="text-xs px-3 py-1 rounded-lg bg-violet-50 text-violet-700 hover:bg-violet-100 font-medium transition disabled:opacity-50"
                          >
                            + Cấp quyền Staff
                          </button>
                        )}
                      </td>
                      <td className="px-4 py-3">
                        <button
                          onClick={() => updateUser(u.id, {
                            email: u.email,
                            role: u.profile?.role ?? 'staff',
                            is_banned: !(u.profile?.is_banned ?? false),
                          })}
                          disabled={busy === u.id}
                          className={`text-xs px-3 py-1 rounded-full font-medium transition disabled:opacity-50 ${
                            u.profile?.is_banned
                              ? 'bg-red-100 text-red-700 hover:bg-red-200'
                              : 'bg-green-100 text-green-700 hover:bg-green-200'
                          }`}
                        >
                          {u.profile?.is_banned ? 'Đã cấm' : 'Hoạt động'}
                        </button>
                      </td>
                      <td className="px-4 py-3 text-gray-500 text-xs">
                        {u.last_sign_in_at
                          ? new Date(u.last_sign_in_at).toLocaleDateString('vi-VN')
                          : 'Chưa đăng nhập'}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </main>
    </div>
  )
}
