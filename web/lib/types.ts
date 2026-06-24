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
  role: 'admin' | 'manager' | 'staff'
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
  payment_method: 'momo' | 'vnpay' | 'zalopay' | 'card' | 'payos' | null
  created_at: string
  plan?: Plan
}

/** Một trang của bài học dạng truyện tranh: 1 ảnh + lời kể. */
export interface StoryPage {
  image_url: string
  caption: string
}

export interface Lesson {
  id?: string
  title: string
  description: string
  youtube_id?: string | null
  /** 'video' = bài giảng YouTube; 'story' = truyện tranh (story_pages). */
  lesson_type?: 'video' | 'story'
  /** Các trang truyện (chỉ dùng khi lesson_type === 'story'). */
  story_pages?: StoryPage[]
  audience: 'child' | 'parent'
  category: string
  thumbnail_emoji: string
  /** Ảnh thumbnail tùy chọn; nếu rỗng thì hiển thị thumbnail_emoji. */
  thumbnail_url?: string
  duration_seconds: number
  order_index: number
  is_published: boolean
  created_at?: string
  lesson_quizzes?: LessonQuiz[]
}

// ───────────────────────────────────────────────────────────────
// GrowWise user app types (mirror mobile/lib/models + DB columns)
// Shared Supabase tables: families, children, tasks, task_submissions,
// badges, dream_items, memories, user_settings, profiles
// ───────────────────────────────────────────────────────────────

export type TaskStatus = 'pending' | 'submitted' | 'approved' | 'rejected'

export interface Family {
  id: string
  name?: string
  parent_id: string
  created_at?: string
}

export interface AppProfile {
  id: string
  full_name?: string | null
  avatar_url?: string | null
  parent_pin_hash?: string | null
}

export interface Child {
  id: string
  family_id: string
  user_id: string | null
  name: string
  age: number
  date_of_birth?: string | null  // ISO "YYYY-MM-DD"; age is derived from this
  avatar_emoji: string
  level: number
  total_coins: number
  spend_jar: number
  save_jar: number
  share_jar: number
  xp: number
  xp_to_next_level: number
  avatar_url?: string | null
  child_pin_hash?: string | null
  created_at?: string
  updated_at?: string
}

/** Calculate age in whole years from an ISO date string ("YYYY-MM-DD"). */
export function calcAge(dob: string): number {
  return Math.floor((Date.now() - new Date(dob).getTime()) / (365.25 * 24 * 60 * 60 * 1000))
}

export interface Task {
  id: string
  family_id: string
  child_id: string
  created_by: string
  title: string
  description: string
  category: string
  icon: string
  coin_reward: number
  status?: TaskStatus
  is_template: boolean
  is_active: boolean
  approval_count: number
  due_date: string | null
  has_penalty: boolean
  penalty_percent: number
  auto_approve_after: number | null
  created_at: string
}

export interface TaskSubmission {
  id: string
  task_id: string
  child_id: string
  status: TaskStatus
  proof_image_url: string | null
  parent_note: string | null
  quality_rating: number | null
  coin_earned: number | null
  submitted_at: string | null
  reviewed_at: string | null
  auto_approved: boolean
  /** Xu đã duyệt nhưng chưa "collect" vào hũ (true sau khi bé chọn hũ). */
  collected?: boolean
  created_at: string
}

/** A task template joined with its active submission (mirror mobile TaskModel). */
export interface TaskWithSubmission extends Task {
  submission_id?: string | null
  submission?: TaskSubmission | null
}

export interface Badge {
  id: string
  child_id: string
  title: string
  emoji: string
  earned_at: string
}

export interface DreamItem {
  id: string
  child_id: string
  name: string
  price: number
  icon: string
  is_purchased: boolean
  created_at: string
}

export interface Memory {
  id: string
  family_id: string
  child_id: string
  task_title: string
  emoji: string
  note: string
  proof_image_url: string | null
  created_at: string
}

export interface UserSettings {
  user_id: string
  locale?: string
  notifications_enabled?: boolean
  bonding_message?: string | null
  updated_at?: string
}
