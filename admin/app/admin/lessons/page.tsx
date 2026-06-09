'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase'
import type { Lesson } from '@/lib/types'

const CATEGORIES = ['Tiết kiệm', 'Đầu tư', 'Chi tiêu', 'Kiếm tiền']

const AUDIENCE_ICON: Record<string, string> = {
  child: 'child_care',
  parent: 'family_history',
}

const AUDIENCE_LABEL: Record<string, string> = {
  child: 'Trẻ em',
  parent: 'Phụ huynh',
}

export default function LessonsPage() {
  const [lessons, setLessons] = useState<Lesson[]>([])
  const [loading, setLoading] = useState(true)
  const [audienceFilter, setAudienceFilter] = useState<'all' | 'child' | 'parent'>('all')
  const [categoryFilter, setCategoryFilter] = useState<string>('all')

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

  const filtered = lessons.filter(l => {
    const matchAudience = audienceFilter === 'all' || l.audience === audienceFilter
    const matchCategory = categoryFilter === 'all' || l.category === categoryFilter
    return matchAudience && matchCategory
  })

  return (
    <div className="p-6 max-w-[1440px] mx-auto">
      {/* Title & Action */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div className="flex items-center gap-3">
          <h2 className="text-3xl font-bold text-on-surface">📚 Bài học</h2>
          <span className="px-2 py-1 bg-surface-container-high rounded-full text-xs font-semibold text-outline">
            {lessons.length} bài học
          </span>
        </div>
        <Link
          href="/admin/lessons/new"
          className="flex items-center gap-2 bg-primary text-on-primary px-6 py-2 rounded-lg text-sm font-semibold hover:opacity-90 transition-all shadow-sm active:scale-95"
        >
          <span className="material-symbols-outlined text-[18px]">add</span>
          Thêm bài học
        </Link>
      </div>

      {/* Filter Bar */}
      <div className="flex flex-wrap items-center gap-4 mb-8">
        {/* Audience dropdown */}
        <div className="relative">
          <select
            value={audienceFilter}
            onChange={e => setAudienceFilter(e.target.value as 'all' | 'child' | 'parent')}
            className="flex items-center gap-2 px-4 py-2 bg-surface-container-lowest border border-outline-variant rounded-lg text-sm text-on-surface hover:border-primary transition-colors outline-none pr-8 appearance-none cursor-pointer"
          >
            <option value="all">Tất cả đối tượng</option>
            <option value="child">Trẻ em</option>
            <option value="parent">Phụ huynh</option>
          </select>
          <span className="material-symbols-outlined absolute right-2 top-1/2 -translate-y-1/2 text-on-surface-variant text-[18px] pointer-events-none">expand_more</span>
        </div>

        {/* Category chips */}
        <div className="flex gap-2">
          <button
            onClick={() => setCategoryFilter('all')}
            className={`px-4 py-2 rounded-full text-sm transition-colors ${
              categoryFilter === 'all'
                ? 'bg-primary/10 text-primary font-semibold'
                : 'hover:bg-surface-container-high text-on-surface-variant'
            }`}
          >
            Tất cả
          </button>
          {CATEGORIES.map(cat => (
            <button
              key={cat}
              onClick={() => setCategoryFilter(cat)}
              className={`px-4 py-2 rounded-full text-sm transition-colors ${
                categoryFilter === cat
                  ? 'bg-primary/10 text-primary font-semibold'
                  : 'hover:bg-surface-container-high text-on-surface-variant'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* Lesson Grid */}
      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {[0,1,2,3,4,5].map(i => (
            <div key={i} className="bg-surface-container-lowest border border-outline-variant rounded-xl overflow-hidden animate-pulse">
              <div className="h-40 bg-surface-container" />
              <div className="p-4 space-y-2">
                <div className="h-5 bg-surface-container-high rounded w-3/4" />
                <div className="h-4 bg-surface-container rounded w-1/2" />
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filtered.map(lesson => (
            <div
              key={lesson.id}
              className="group bg-surface-container-lowest border border-outline-variant rounded-xl overflow-hidden flex flex-col hover:-translate-y-1 hover:shadow-lg transition-all duration-200"
            >
              {/* Banner */}
              <div className="h-40 bg-surface-container flex items-center justify-center relative overflow-hidden">
                <span className="text-6xl z-10">{lesson.thumbnail_emoji || '📚'}</span>
                {lesson.category && (
                  <div className="absolute top-2 right-2">
                    <span className="px-2 py-1 bg-surface-container-highest text-on-surface-variant rounded-full text-xs font-semibold">
                      {lesson.category}
                    </span>
                  </div>
                )}
              </div>

              {/* Content */}
              <div className="p-4 flex-1 flex flex-col">
                <h3 className="text-base font-bold text-on-surface mb-2 line-clamp-2">{lesson.title}</h3>

                {/* Meta */}
                <div className="flex items-center gap-4 mb-4">
                  <div className="flex items-center gap-1 text-outline text-xs">
                    <span className="material-symbols-outlined text-[14px]">schedule</span>
                    {Math.round(lesson.duration_seconds / 60)} phút
                  </div>
                  <div className="flex items-center gap-1 text-outline text-xs">
                    <span className="material-symbols-outlined text-[14px]">{AUDIENCE_ICON[lesson.audience] ?? 'person'}</span>
                    {AUDIENCE_LABEL[lesson.audience] ?? lesson.audience}
                  </div>
                </div>

                {/* Footer */}
                <div className="mt-auto pt-3 border-t border-outline-variant flex items-center justify-between">
                  {/* Toggle */}
                  <label className="relative inline-flex items-center cursor-pointer gap-2">
                    <input
                      type="checkbox"
                      checked={lesson.is_published}
                      onChange={() => togglePublish(lesson)}
                      className="sr-only peer"
                    />
                    <div className="w-10 h-5 bg-surface-variant rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-primary relative" />
                    <span className="text-xs text-outline">
                      {lesson.is_published ? 'Đã đăng' : 'Bản nháp'}
                    </span>
                  </label>

                  {/* Actions */}
                  <div className="flex gap-1">
                    <Link
                      href={`/admin/lessons/${lesson.id}`}
                      className="p-1.5 text-outline hover:text-primary hover:bg-surface-container-high rounded-full transition-colors"
                    >
                      <span className="material-symbols-outlined text-[18px]">edit</span>
                    </Link>
                    <button
                      onClick={() => deleteLesson(lesson.id!)}
                      className="p-1.5 text-outline hover:text-error hover:bg-error-container/10 rounded-full transition-colors"
                    >
                      <span className="material-symbols-outlined text-[18px]">delete</span>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          ))}

          {/* Create new placeholder */}
          <Link
            href="/admin/lessons/new"
            className="group bg-surface-container-lowest border-2 border-dashed border-outline-variant rounded-xl flex flex-col items-center justify-center py-12 hover:border-primary hover:bg-surface-container transition-all cursor-pointer min-h-[300px]"
          >
            <div className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center text-primary mb-3 group-hover:scale-110 transition-transform">
              <span className="material-symbols-outlined text-2xl">add</span>
            </div>
            <p className="text-sm font-medium text-outline group-hover:text-primary">Tạo bài học mới</p>
          </Link>
        </div>
      )}
    </div>
  )
}
