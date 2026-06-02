export interface QuizOption {
  id?: string
  quiz_id?: string
  text: string
  emoji: string
  order_index: number
}

export interface LessonQuiz {
  id?: string
  lesson_id?: string
  trigger_at: number
  question: string
  correct_index: number
  explanation: string
  order_index: number
  quiz_options?: QuizOption[]
}

export interface Profile {
  id: string
  email: string
  role: 'admin' | 'staff'
  is_banned: boolean
  access_granted: boolean
  created_at: string
}

export interface Lesson {
  id?: string
  title: string
  description: string
  youtube_id: string
  audience: 'child' | 'parent'
  category: string
  thumbnail_emoji: string
  duration_seconds: number
  order_index: number
  is_published: boolean
  created_at?: string
  lesson_quizzes?: LessonQuiz[]
}
