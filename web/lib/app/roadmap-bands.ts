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
