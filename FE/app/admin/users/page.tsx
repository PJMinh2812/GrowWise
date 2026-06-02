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
    await fetch(`/api/admin/users/${id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(patch),
    })
    await fetchUsers()
    setBusy(null)
  }

  async function deleteUser(id: string, email: string) {
    if (!confirm(`Xóa tài khoản ${email}? Hành động này không thể hoàn tác.`)) return
    setBusy(id)
    await fetch(`/api/admin/users/${id}`, { method: 'DELETE' })
    setUsers(prev => prev.filter(u => u.id !== id))
    setBusy(null)
  }

  const roleLabel = (role: string | undefined) =>
    role === 'admin' ? 'Admin' : role === 'staff' ? 'Staff' : 'Chưa có'

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

      <main className="max-w-5xl mx-auto px-6 py-8">
        <div className="mb-6">
          <h2 className="text-xl font-bold text-gray-900">Quản lý người dùng</h2>
          <p className="text-sm text-gray-500">{users.length} tài khoản</p>
        </div>

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
                  <th className="px-4 py-3"></th>
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
                        <span className="text-xs text-gray-400">Chưa có profile</span>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      {u.profile ? (
                        <button
                          onClick={() => updateUser(u.id, { email: u.email, role: u.profile!.role, is_banned: !u.profile!.is_banned })}
                          disabled={busy === u.id}
                          className={`text-xs px-3 py-1 rounded-full font-medium transition disabled:opacity-50 ${
                            u.profile.is_banned
                              ? 'bg-red-100 text-red-700 hover:bg-red-200'
                              : 'bg-green-100 text-green-700 hover:bg-green-200'
                          }`}
                        >
                          {u.profile.is_banned ? 'Đã cấm' : 'Hoạt động'}
                        </button>
                      ) : (
                        <span className="text-xs text-gray-400">—</span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-gray-500 text-xs">
                      {u.last_sign_in_at
                        ? new Date(u.last_sign_in_at).toLocaleDateString('vi-VN')
                        : 'Chưa đăng nhập'}
                    </td>
                    <td className="px-4 py-3 text-right">
                      <button
                        onClick={() => deleteUser(u.id, u.email)}
                        disabled={busy === u.id}
                        className="text-xs px-3 py-1.5 rounded-lg bg-red-50 text-red-600 hover:bg-red-100 font-medium transition disabled:opacity-50"
                      >
                        Xóa
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </main>
    </div>
  )
}
