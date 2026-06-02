'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase'
import type { LessonQuiz, QuizOption } from '@/lib/types'

const EMPTY_QUIZ: Omit<LessonQuiz, 'id' | 'lesson_id'> = {
  trigger_at: 0,
  question: '',
  correct_index: 0,
  explanation: '',
  order_index: 0,
  quiz_options: [
    { text: '', emoji: '✅', order_index: 0 },
    { text: '', emoji: '❌', order_index: 1 },
    { text: '', emoji: '🤔', order_index: 2 },
  ],
}

export default function QuizEditor({ lessonId }: { lessonId: string }) {
  const [quizzes, setQuizzes] = useState<LessonQuiz[]>([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState<string | null>(null)

  useEffect(() => { fetchQuizzes() }, [lessonId])

  async function fetchQuizzes() {
    const supabase = createClient()
    const { data } = await supabase
      .from('lesson_quizzes')
      .select('*, quiz_options(*)')
      .eq('lesson_id', lessonId)
      .order('order_index')
    setQuizzes(
      (data ?? []).map(q => ({
        ...q,
        quiz_options: [...(q.quiz_options ?? [])].sort((a, b) => a.order_index - b.order_index),
      }))
    )
    setLoading(false)
  }

  function addQuiz() {
    setQuizzes(prev => [
      ...prev,
      { ...EMPTY_QUIZ, order_index: prev.length, quiz_options: EMPTY_QUIZ.quiz_options!.map(o => ({ ...o })) } as LessonQuiz,
    ])
  }

  function updateQuiz(index: number, key: keyof LessonQuiz, value: unknown) {
    setQuizzes(prev => prev.map((q, i) => i === index ? { ...q, [key]: value } : q))
  }

  function updateOption(quizIndex: number, optIndex: number, key: keyof QuizOption, value: string) {
    setQuizzes(prev => prev.map((q, i) => {
      if (i !== quizIndex) return q
      const opts = (q.quiz_options ?? []).map((o, j) => j === optIndex ? { ...o, [key]: value } : o)
      return { ...q, quiz_options: opts }
    }))
  }

  async function saveQuiz(index: number) {
    const quiz = quizzes[index]
    setSaving(`${index}`)
    const supabase = createClient()

    if (quiz.id) {
      // Update existing quiz
      await supabase.from('lesson_quizzes').update({
        trigger_at: quiz.trigger_at,
        question: quiz.question,
        correct_index: quiz.correct_index,
        explanation: quiz.explanation,
        order_index: quiz.order_index,
      }).eq('id', quiz.id)

      // Upsert options
      const options = (quiz.quiz_options ?? []).map((o, j) => ({
        ...o,
        quiz_id: quiz.id,
        order_index: j,
      }))
      for (const opt of options) {
        if (opt.id) {
          await supabase.from('quiz_options').update({ text: opt.text, emoji: opt.emoji, order_index: opt.order_index }).eq('id', opt.id)
        } else {
          await supabase.from('quiz_options').insert({ quiz_id: quiz.id, text: opt.text, emoji: opt.emoji, order_index: opt.order_index })
        }
      }
    } else {
      // Insert new quiz
      const { data: newQuiz } = await supabase.from('lesson_quizzes').insert({
        lesson_id: lessonId,
        trigger_at: quiz.trigger_at,
        question: quiz.question,
        correct_index: quiz.correct_index,
        explanation: quiz.explanation,
        order_index: quiz.order_index,
      }).select().single()

      if (newQuiz) {
        const options = (quiz.quiz_options ?? []).map((o, j) => ({
          quiz_id: newQuiz.id,
          text: o.text,
          emoji: o.emoji,
          order_index: j,
        }))
        await supabase.from('quiz_options').insert(options)
        setQuizzes(prev => prev.map((q, i) => i === index ? { ...q, id: newQuiz.id } : q))
      }
    }

    setSaving(null)
  }

  async function deleteQuiz(index: number) {
    const quiz = quizzes[index]
    if (!confirm('Xóa câu hỏi này?')) return
    if (quiz.id) {
      const supabase = createClient()
      await supabase.from('lesson_quizzes').delete().eq('id', quiz.id)
    }
    setQuizzes(prev => prev.filter((_, i) => i !== index))
  }

  if (loading) return <div className="text-sm text-gray-400">Đang tải câu hỏi...</div>

  return (
    <div className="bg-white border border-gray-200 rounded-xl p-6">
      <div className="flex items-center justify-between mb-4">
        <h2 className="font-semibold text-gray-900">Câu hỏi tương tác ({quizzes.length})</h2>
        <button
          onClick={addQuiz}
          className="text-sm bg-violet-50 text-violet-700 px-3 py-1.5 rounded-lg font-medium hover:bg-violet-100 transition"
        >
          + Thêm câu hỏi
        </button>
      </div>

      {quizzes.length === 0 && (
        <p className="text-sm text-gray-400 text-center py-6">Chưa có câu hỏi nào. Thêm câu hỏi để học sinh tương tác trong lúc xem video.</p>
      )}

      <div className="space-y-6">
        {quizzes.map((quiz, qi) => (
          <div key={quiz.id ?? `new-${qi}`} className="border border-gray-100 rounded-xl p-4 space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium text-gray-700">Câu hỏi {qi + 1}</span>
              <div className="flex gap-2">
                <button
                  onClick={() => saveQuiz(qi)}
                  disabled={saving === `${qi}`}
                  className="text-xs bg-green-50 text-green-700 px-3 py-1 rounded-lg font-medium hover:bg-green-100 disabled:opacity-50 transition"
                >
                  {saving === `${qi}` ? 'Đang lưu...' : 'Lưu'}
                </button>
                <button
                  onClick={() => deleteQuiz(qi)}
                  className="text-xs bg-red-50 text-red-600 px-3 py-1 rounded-lg font-medium hover:bg-red-100 transition"
                >
                  Xóa
                </button>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="text-xs text-gray-500 mb-1 block">Hiện lúc (giây)</label>
                <input
                  type="number"
                  value={quiz.trigger_at}
                  onChange={e => updateQuiz(qi, 'trigger_at', parseInt(e.target.value) || 0)}
                  className="w-full border border-gray-200 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500"
                />
              </div>
              <div>
                <label className="text-xs text-gray-500 mb-1 block">Đáp án đúng (số thứ tự, bắt đầu từ 0)</label>
                <input
                  type="number"
                  value={quiz.correct_index}
                  min={0}
                  max={(quiz.quiz_options?.length ?? 1) - 1}
                  onChange={e => updateQuiz(qi, 'correct_index', parseInt(e.target.value) || 0)}
                  className="w-full border border-gray-200 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500"
                />
              </div>
              <div className="col-span-2">
                <label className="text-xs text-gray-500 mb-1 block">Câu hỏi</label>
                <input
                  value={quiz.question}
                  onChange={e => updateQuiz(qi, 'question', e.target.value)}
                  className="w-full border border-gray-200 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500"
                  placeholder="Nhập câu hỏi..."
                />
              </div>
              <div className="col-span-2">
                <label className="text-xs text-gray-500 mb-1 block">Giải thích sau khi trả lời</label>
                <input
                  value={quiz.explanation}
                  onChange={e => updateQuiz(qi, 'explanation', e.target.value)}
                  className="w-full border border-gray-200 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500"
                  placeholder="Giải thích đáp án đúng..."
                />
              </div>
            </div>

            {/* Options */}
            <div>
              <label className="text-xs text-gray-500 mb-2 block">Các lựa chọn</label>
              <div className="space-y-2">
                {(quiz.quiz_options ?? []).map((opt, oi) => (
                  <div key={oi} className={`flex gap-2 items-center p-2 rounded-lg ${oi === quiz.correct_index ? 'bg-green-50 border border-green-200' : 'bg-gray-50'}`}>
                    <span className="text-xs text-gray-400 w-4">{oi}.</span>
                    <input
                      value={opt.emoji}
                      onChange={e => updateOption(qi, oi, 'emoji', e.target.value)}
                      className="w-12 border border-gray-200 rounded px-2 py-1 text-sm text-center focus:outline-none"
                      placeholder="🔢"
                    />
                    <input
                      value={opt.text}
                      onChange={e => updateOption(qi, oi, 'text', e.target.value)}
                      className="flex-1 border border-gray-200 rounded-lg px-3 py-1 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500"
                      placeholder={`Lựa chọn ${oi + 1}...`}
                    />
                    {oi === quiz.correct_index && <span className="text-xs text-green-600 font-medium">✓ Đúng</span>}
                  </div>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
