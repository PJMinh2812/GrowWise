/**
 * Age-based starter roadmap data (no 'use server' — importable from API routes
 * and server actions alike). Each band has ready-made daily tasks; the AI wizard
 * personalizes on top and parents can edit afterwards.
 */
export interface RoadmapTask {
  title: string
  description: string
  category: string
  icon: string
  coin_reward: number
  auto_approve?: boolean
  has_penalty?: boolean
  penalty_percent?: number
  /** Giờ hẹn 'HH:MM' (timeline). */
  scheduled_time?: string | null
  duration_minutes?: number
  frequency?: string
  stage?: number
}

export interface RoadmapStageSeed {
  month: number
  theme: string
  goal: string
  lesson_category: string
  milestone: string
}

/**
 * Fallback 12-stage money curriculum (1 year). Used when the AI is unavailable
 * so the roadmap still has a progressive arc: earn → 3 jars → saving goal →
 * smart spending → sharing → budgeting → review.
 */
export const FALLBACK_STAGES: RoadmapStageSeed[] = [
  { month: 1, theme: 'Làm quen với xu & thói quen', goal: 'Hiểu xu kiếm từ việc tốt', lesson_category: 'Cơ bản', milestone: 'Hoàn thành 5 ngày liên tục' },
  { month: 2, theme: 'Hệ thống 3 hũ', goal: 'Biết chia Tiêu/Tiết kiệm/Chia sẻ', lesson_category: 'Tiết kiệm', milestone: 'Chia xu vào đủ 3 hũ' },
  { month: 3, theme: 'Mục tiêu tiết kiệm nhỏ', goal: 'Đặt và đạt 1 mục tiêu nhỏ', lesson_category: 'Tiết kiệm', milestone: 'Mua được 1 món mơ ước' },
  { month: 4, theme: 'Chi tiêu thông minh', goal: 'Phân biệt cần và muốn', lesson_category: 'Chi tiêu', milestone: 'Tự quyết 1 lần mua' },
  { month: 5, theme: 'Kiên nhẫn & trì hoãn', goal: 'Chờ để tiết kiệm nhiều hơn', lesson_category: 'Tiết kiệm', milestone: 'Dồn xu 2 tuần' },
  { month: 6, theme: 'Chia sẻ & cho đi', goal: 'Dùng hũ Chia sẻ ý nghĩa', lesson_category: 'Chia sẻ', milestone: 'Làm 1 việc chia sẻ' },
  { month: 7, theme: 'Mục tiêu lớn', goal: 'Lập kế hoạch món lớn', lesson_category: 'Tiết kiệm', milestone: 'Đạt 50% mục tiêu lớn' },
  { month: 8, theme: 'Ghi chép Thu/Chi', goal: 'Theo dõi tiền vào ra', lesson_category: 'Quản lý', milestone: 'Ghi đủ Thu/Chi 1 tuần' },
  { month: 9, theme: 'Lập ngân sách', goal: 'Phân bổ xu theo kế hoạch', lesson_category: 'Quản lý', milestone: 'Lập 1 ngân sách tuần' },
  { month: 10, theme: 'Tránh lãng phí', goal: 'Nhận ra chi tiêu bốc đồng', lesson_category: 'Chi tiêu', milestone: 'Tuần không chi bốc đồng' },
  { month: 11, theme: 'Kiếm thêm xu', goal: 'Làm thêm việc có ích', lesson_category: 'Cơ bản', milestone: 'Hoàn thành nhiệm vụ thưởng' },
  { month: 12, theme: 'Tổng kết & tự quản', goal: 'Tự quản lý tiền cơ bản', lesson_category: 'Quản lý', milestone: 'Đạt mục tiêu lớn cả năm' },
]

/** Extra habit tasks offered in "Gợi ý thêm nhiệm vụ". */
export const SUGGEST_POOL: RoadmapTask[] = [
  { title: 'Tưới cây', description: 'Chăm cây mỗi ngày', category: 'Việc nhà', icon: '🪴', coin_reward: 20, scheduled_time: '06:45', duration_minutes: 10 },
  { title: 'Gấp quần áo', description: 'Gấp và cất quần áo', category: 'Việc nhà', icon: '👕', coin_reward: 30, scheduled_time: '20:00', duration_minutes: 15 },
  { title: 'Thiền 5 phút', description: 'Ngồi yên hít thở', category: 'Sức khỏe', icon: '🧘', coin_reward: 20, scheduled_time: '21:00', duration_minutes: 5 },
  { title: 'Viết nhật ký', description: 'Ghi lại điều hôm nay', category: 'Sáng tạo', icon: '📓', coin_reward: 30, scheduled_time: '20:45', duration_minutes: 10 },
  { title: 'Học tiếng Anh', description: 'Học từ mới mỗi ngày', category: 'Học tập', icon: '🔤', coin_reward: 40, scheduled_time: '18:00', duration_minutes: 15 },
  { title: 'Bỏ heo đất', description: 'Bỏ xu tiết kiệm mỗi ngày', category: 'Học tập', icon: '🐷', coin_reward: 25, scheduled_time: '21:15', duration_minutes: 5 },
  { title: 'Uống đủ nước', description: 'Uống nước đều trong ngày', category: 'Sức khỏe', icon: '💧', coin_reward: 15, scheduled_time: '12:00', duration_minutes: 5 },
  { title: 'Đọc 1 trang sách', description: 'Đọc thêm mỗi tối', category: 'Học tập', icon: '📕', coin_reward: 30, scheduled_time: '20:30', duration_minutes: 15 },
]

/** Spread tasks across sensible default times when none is given. */
const DEFAULT_TIMES = ['07:00', '07:30', '17:30', '18:30', '19:30', '20:30']

/** Enrich plain band tasks with default schedule so the timeline looks right. */
export function withSchedule(tasks: RoadmapTask[]): RoadmapTask[] {
  return tasks.map((t, i) => ({
    ...t,
    scheduled_time: t.scheduled_time ?? DEFAULT_TIMES[i % DEFAULT_TIMES.length],
    duration_minutes: t.duration_minutes ?? 15,
    frequency: t.frequency ?? 'daily',
    auto_approve: t.auto_approve ?? true,
    has_penalty: t.has_penalty ?? true,
    penalty_percent: t.penalty_percent ?? 10,
    stage: t.stage ?? 1,
  }))
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

export function bandFor(age: number): RoadmapTask[] {
  return (BANDS.find((b) => age < b.max) ?? BANDS[BANDS.length - 1]).tasks
}
