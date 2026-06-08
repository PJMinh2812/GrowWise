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
  question_type?: 'single' | 'multi'
  correct_index: number
  correct_indices?: number[]
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

export interface Plan {
  id: string
  name: 'free' | 'premium' | 'family'
  display_name: string
  price_monthly: number
  price_yearly: number | null
  max_children: number
  max_daily_ai_messages: number
  max_active_tasks: number
  max_lessons: number
  features: string[]
  is_active: boolean
  created_at: string
}

export interface UserSubscription {
  id: string
  user_id: string
  plan_id: string
  status: 'active' | 'canceled' | 'expired' | 'trial'
  billing_interval: 'monthly' | 'yearly'
  trial_ends_at: string | null
  current_period_start: string
  current_period_end: string | null
  payment_method: 'momo' | 'vnpay' | 'zalopay' | 'card' | null
  created_at: string
  plan?: Plan
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
