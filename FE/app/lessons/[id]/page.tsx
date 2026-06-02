'use client'

import { useEffect, useState } from 'react'
import { useParams } from 'next/navigation'
import { createClient } from '@/lib/supabase'
import LessonForm from '@/components/LessonForm'
import type { Lesson } from '@/lib/types'

export default function EditLessonPage() {
  const { id } = useParams<{ id: string }>()
  const [lesson, setLesson] = useState<Lesson | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function fetch() {
      const supabase = createClient()
      const { data } = await supabase.from('lessons').select('*').eq('id', id).single()
      setLesson(data as Lesson)
      setLoading(false)
    }
    fetch()
  }, [id])

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center text-gray-400">
        Đang tải...
      </div>
    )
  }

  if (!lesson) {
    return (
      <div className="min-h-screen flex items-center justify-center text-gray-400">
        Không tìm thấy bài học
      </div>
    )
  }

  return <LessonForm initial={lesson} lessonId={id} />
}
