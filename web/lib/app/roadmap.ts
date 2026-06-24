'use server'

import { revalidatePath } from 'next/cache'
import { createServerSupabase } from '@/lib/supabase-server'

/**
 * Age-based starter roadmap. Each band has a small set of ready-made tasks so a
 * busy parent doesn't have to create them. Tasks auto-approve (auto_approve_after
 * = 0) → the flow runs on its own; the child still "collects" coins into a jar.
 * Parents can edit/disable any of them afterwards.
 */
interface RoadmapTask {
  title: string
  description: string
  category: string
  icon: string
  coin_reward: number
}

const BANDS: { max: number; tasks: RoadmapTask[] }[] = [
  {
    max: 6, // < 6 tuổi
    tasks: [
      { title: 'Cất đồ chơi gọn gàng', description: 'Dọn đồ chơi vào đúng chỗ sau khi chơi', category: 'Việc nhà', icon: '🧸', coin_reward: 20 },
      { title: 'Tự đánh răng', description: 'Đánh răng sáng và tối', category: 'Sức khỏe', icon: '🪥', coin_reward: 20 },
      { title: 'Bỏ heo đất 1 đồng xu', description: 'Tập thói quen tiết kiệm mỗi ngày', category: 'Học tập', icon: '🐷', coin_reward: 30 },
      { title: 'Nói lời cảm ơn', description: 'Cảm ơn khi được giúp đỡ', category: 'Sáng tạo', icon: '💛', coin_reward: 15 },
    ],
  },
  {
    max: 9, // 6–8 tuổi
    tasks: [
      { title: 'Dọn bàn học', description: 'Sắp xếp bàn học ngăn nắp', category: 'Việc nhà', icon: '📚', coin_reward: 30 },
      { title: 'Đọc sách 15 phút', description: 'Đọc một câu chuyện yêu thích', category: 'Học tập', icon: '📖', coin_reward: 40 },
      { title: 'Phụ dọn bàn ăn', description: 'Giúp ba mẹ dọn bàn trước/sau bữa ăn', category: 'Việc nhà', icon: '🍽️', coin_reward: 30 },
      { title: 'Tiết kiệm cho mục tiêu nhỏ', description: 'Bỏ xu vào hũ Tiết kiệm cho món con thích', category: 'Học tập', icon: '🎯', coin_reward: 40 },
      { title: 'Chia sẻ với bạn/em', description: 'Chia sẻ đồ chơi hoặc đồ ăn', category: 'Sáng tạo', icon: '🤝', coin_reward: 25 },
    ],
  },
  {
    max: 12, // 9–11 tuổi
    tasks: [
      { title: 'Tự soạn cặp đi học', description: 'Chuẩn bị sách vở cho ngày mai', category: 'Học tập', icon: '🎒', coin_reward: 40 },
      { title: 'Làm bài tập về nhà', description: 'Hoàn thành bài tập đúng hạn', category: 'Học tập', icon: '✏️', coin_reward: 60 },
      { title: 'Phụ việc nhà 20 phút', description: 'Quét nhà, gấp quần áo hoặc rửa chén', category: 'Việc nhà', icon: '🧹', coin_reward: 50 },
      { title: 'Lập kế hoạch tiết kiệm tuần', description: 'Đặt mục tiêu tiết kiệm và theo dõi', category: 'Học tập', icon: '📈', coin_reward: 50 },
      { title: 'Tập thể dục 15 phút', description: 'Vận động cho khỏe mỗi ngày', category: 'Sức khỏe', icon: '💪', coin_reward: 30 },
    ],
  },
  {
    max: 16, // 12–15 tuổi
    tasks: [
      { title: 'Quản lý thời gian học', description: 'Học theo lịch và tự đánh giá', category: 'Học tập', icon: '⏰', coin_reward: 70 },
      { title: 'Tự nấu/chuẩn bị một bữa nhẹ', description: 'Chuẩn bị bữa sáng hoặc bữa phụ', category: 'Việc nhà', icon: '🥪', coin_reward: 60 },
      { title: 'Lập ngân sách chi tiêu', description: 'Ghi lại Thu/Chi trong tuần', category: 'Học tập', icon: '💰', coin_reward: 80 },
      { title: 'Tiết kiệm cho mục tiêu lớn', description: 'Dành xu cho mục tiêu dài hạn', category: 'Học tập', icon: '🏦', coin_reward: 70 },
      { title: 'Giúp đỡ thành viên gia đình', description: 'Hỗ trợ một việc cụ thể trong nhà', category: 'Sáng tạo', icon: '❤️', coin_reward: 50 },
    ],
  },
  {
    max: 200, // > 15 tuổi
    tasks: [
      { title: 'Lập kế hoạch tài chính tháng', description: 'Đặt mục tiêu thu/chi và tiết kiệm', category: 'Học tập', icon: '🗂️', coin_reward: 100 },
      { title: 'Tự học một kỹ năng mới', description: 'Dành thời gian học kỹ năng hữu ích', category: 'Học tập', icon: '🚀', coin_reward: 90 },
      { title: 'Phụ trách một việc nhà cố định', description: 'Đảm nhận đều đặn một công việc', category: 'Việc nhà', icon: '🧺', coin_reward: 70 },
      { title: 'Theo dõi & tối ưu chi tiêu', description: 'Xem lại Thu/Chi và điều chỉnh', category: 'Học tập', icon: '📊', coin_reward: 90 },
    ],
  },
]

function bandFor(age: number): RoadmapTask[] {
  return (BANDS.find((b) => age < b.max) ?? BANDS[BANDS.length - 1]).tasks
}

/**
 * Seed the age-appropriate roadmap tasks for a child. Idempotent: does nothing
 * if the child already has active task templates (so it won't duplicate).
 * Tasks auto-approve so the routine runs without parent effort.
 */
export async function seedRoadmapForChild(childId: string) {
  if (!childId) return { ok: false, error: 'missing childId' }
  const supabase = await createServerSupabase()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return { ok: false, error: 'unauthorized' }

  const { data: family } = await supabase
    .from('families')
    .select('id')
    .eq('parent_id', user.id)
    .maybeSingle()
  if (!family) return { ok: false, error: 'no family' }

  const { data: child } = await supabase
    .from('children')
    .select('id, age')
    .eq('id', childId)
    .eq('family_id', family.id)
    .maybeSingle()
  if (!child) return { ok: false, error: 'unauthorized' }

  // Idempotent: skip if the child already has active templates.
  const { count } = await supabase
    .from('tasks')
    .select('id', { count: 'exact', head: true })
    .eq('child_id', childId)
    .eq('is_template', true)
    .eq('is_active', true)
  if ((count ?? 0) > 0) return { ok: true, seeded: 0 }

  const tasks = bandFor((child.age as number) ?? 8)
  const rows = tasks.map((t) => ({
    family_id: family.id,
    child_id: childId,
    created_by: user.id,
    title: t.title,
    description: t.description,
    category: t.category,
    icon: t.icon,
    coin_reward: t.coin_reward,
    is_template: true,
    is_active: true,
    approval_count: 0,
    has_penalty: false,
    penalty_percent: 10,
    auto_approve_after: 0, // tự duyệt → lộ trình tự chạy
  }))
  const { error } = await supabase.from('tasks').insert(rows)
  if (error) return { ok: false, error: error.message }

  revalidatePath('/child')
  revalidatePath('/child/tasks')
  revalidatePath('/parent')
  return { ok: true, seeded: rows.length }
}
