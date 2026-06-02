'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase'
import type { Lesson } from '@/lib/types'

function getUserRole(): string {
  if (typeof document === 'undefined') return ''
  return document.cookie.split('; ').find(r => r.startsWith('x-user-role='))?.split('=')[1] ?? ''
}

export default function LessonsPage() {
  const router = useRouter()
  const [lessons, setLessons] = useState<Lesson[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState<'all' | 'child' | 'parent'>('all')
  const [role, setRole] = useState('')

  useEffect(() => { setRole(getUserRole()) }, [])

  useEffect(() => { fetchLessons() }, [])

  async function fetchLessons() {
    const supabase = createClient()
    const { data } = await supabase
      .from('lessons')
      .select('*')
      .order('order_index')
    setLessons(data ?? [])
    setLoading(false)
  }

  async function togglePublish(lesson: Lesson) {
    const supabase = createClient()
    await supabase.from('lessons').update({ is_published: !lesson.is_published }).eq('id', lesson.id!)
    setLessons(prev => prev.map(l => l.id === lesson.id ? { ...l, is_published: !l.is_published } : l))
  }

  async function deleteLesson(id: string) {
    if (!confirm('Xóa bài học này?')) return
    const supabase = createClient()
    await supabase.from('lessons').delete().eq('id', id)
    setLessons(prev => prev.filter(l => l.id !== id))
  }

  async function handleLogout() {
    const supabase = createClient()
    await supabase.auth.signOut()
    router.push('/login')
  }

  const filtered = filter === 'all' ? lessons : lessons.filter(l => l.audience === filter)

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <span className="text-2xl">🌱</span>
          <h1 className="text-lg font-bold text-gray-900">GrowWise Admin</h1>
        </div>
        <div className="flex items-center gap-4">
          <span className="text-sm font-semibold text-violet-700">Bài học</span>
          {role === 'admin' && (
            <Link href="/admin/users" className="text-sm text-gray-500 hover:text-gray-700">Người dùng</Link>
          )}
          <button onClick={handleLogout} className="text-sm text-gray-400 hover:text-gray-600">Đăng xuất</button>
        </div>
      </header>

      <main className="max-w-5xl mx-auto px-6 py-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h2 className="text-xl font-bold text-gray-900">Danh sách bài học</h2>
            <p className="text-sm text-gray-500">{lessons.length} bài học</p>
          </div>
          <Link
            href="/lessons/new"
            className="bg-violet-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-violet-700 transition"
          >
            + Thêm bài học
          </Link>
        </div>

        {/* Filter tabs */}
        <div className="flex gap-2 mb-4">
          {(['all', 'child', 'parent'] as const).map(f => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`px-4 py-1.5 rounded-full text-sm font-medium transition ${
                filter === f ? 'bg-violet-600 text-white' : 'bg-white text-gray-600 border border-gray-200 hover:bg-gray-50'
              }`}
            >
              {f === 'all' ? 'Tất cả' : f === 'child' ? '👦 Trẻ em' : '👨‍👩‍👧 Phụ huynh'}
            </button>
          ))}
        </div>

        {loading ? (
          <div className="text-center py-12 text-gray-400">Đang tải...</div>
        ) : filtered.length === 0 ? (
          <div className="text-center py-12 text-gray-400">
            <div className="text-4xl mb-2">📭</div>
            <p>Chưa có bài học nào</p>
          </div>
        ) : (
          <div className="space-y-3">
            {filtered.map(lesson => (
              <div key={lesson.id} className="bg-white border border-gray-200 rounded-xl p-4 flex items-center gap-4">
                <div className="text-3xl w-12 h-12 flex items-center justify-center bg-violet-50 rounded-xl flex-shrink-0">
                  {lesson.thumbnail_emoji}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-0.5">
                    <h3 className="font-semibold text-gray-900 truncate">{lesson.title}</h3>
                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${
                      lesson.is_published ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'
                    }`}>
                      {lesson.is_published ? 'Đã đăng' : 'Nháp'}
                    </span>
                  </div>
                  <div className="flex items-center gap-3 text-xs text-gray-500">
                    <span>{lesson.audience === 'child' ? '👦 Trẻ em' : '👨‍👩‍👧 Phụ huynh'}</span>
                    <span>•</span>
                    <span>{lesson.category}</span>
                    <span>•</span>
                    <span>{Math.round(lesson.duration_seconds / 60)} phút</span>
                  </div>
                </div>
                <div className="flex items-center gap-2 flex-shrink-0">
                  <button
                    onClick={() => togglePublish(lesson)}
                    className={`text-xs px-3 py-1.5 rounded-lg font-medium transition ${
                      lesson.is_published
                        ? 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                        : 'bg-green-100 text-green-700 hover:bg-green-200'
                    }`}
                  >
                    {lesson.is_published ? 'Gỡ đăng' : 'Đăng bài'}
                  </button>
                  <Link
                    href={`/lessons/${lesson.id}`}
                    className="text-xs px-3 py-1.5 rounded-lg bg-violet-50 text-violet-700 hover:bg-violet-100 font-medium transition"
                  >
                    Chỉnh sửa
                  </Link>
                  <button
                    onClick={() => deleteLesson(lesson.id!)}
                    className="text-xs px-3 py-1.5 rounded-lg bg-red-50 text-red-600 hover:bg-red-100 font-medium transition"
                  >
                    Xóa
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  )
}
