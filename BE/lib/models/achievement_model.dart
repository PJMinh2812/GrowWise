enum AchievementCategory { streak, category, level, special }

class Achievement {
  final String id;
  final String name;
  final String description;
  final String defaultEmoji;
  final AchievementCategory category;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultEmoji,
    required this.category,
  });
}

// All achievements predefined by the app
const allAchievements = <Achievement>[
  // ── Streak ──────────────────────────────────────────────
  Achievement(
    id: 'streak_3',
    name: 'Chuỗi 3 ngày',
    description: 'Hoàn thành task 3 ngày liên tiếp',
    defaultEmoji: '🔥',
    category: AchievementCategory.streak,
  ),
  Achievement(
    id: 'streak_7',
    name: 'Chuỗi 7 ngày',
    description: 'Hoàn thành task 7 ngày liên tiếp',
    defaultEmoji: '⚡',
    category: AchievementCategory.streak,
  ),
  Achievement(
    id: 'streak_14',
    name: 'Chuỗi 14 ngày',
    description: 'Hoàn thành task 14 ngày liên tiếp',
    defaultEmoji: '💫',
    category: AchievementCategory.streak,
  ),
  Achievement(
    id: 'streak_30',
    name: 'Chuỗi 30 ngày',
    description: 'Hoàn thành task 30 ngày liên tiếp',
    defaultEmoji: '🏆',
    category: AchievementCategory.streak,
  ),

  // ── Category ─────────────────────────────────────────────
  Achievement(
    id: 'housework_5',
    name: 'Siêng năng',
    description: 'Hoàn thành 5 việc nhà',
    defaultEmoji: '🧹',
    category: AchievementCategory.category,
  ),
  Achievement(
    id: 'housework_15',
    name: 'Người giữ nhà',
    description: 'Hoàn thành 15 việc nhà',
    defaultEmoji: '🏠',
    category: AchievementCategory.category,
  ),
  Achievement(
    id: 'study_5',
    name: 'Mọt sách',
    description: 'Hoàn thành 5 nhiệm vụ học tập',
    defaultEmoji: '📚',
    category: AchievementCategory.category,
  ),
  Achievement(
    id: 'study_15',
    name: 'Học giỏi',
    description: 'Hoàn thành 15 nhiệm vụ học tập',
    defaultEmoji: '🎓',
    category: AchievementCategory.category,
  ),
  Achievement(
    id: 'health_5',
    name: 'Năng động',
    description: 'Hoàn thành 5 nhiệm vụ sức khỏe',
    defaultEmoji: '💪',
    category: AchievementCategory.category,
  ),
  Achievement(
    id: 'health_15',
    name: 'Sức khỏe vàng',
    description: 'Hoàn thành 15 nhiệm vụ sức khỏe',
    defaultEmoji: '🏅',
    category: AchievementCategory.category,
  ),
  Achievement(
    id: 'creative_5',
    name: 'Tài năng',
    description: 'Hoàn thành 5 nhiệm vụ sáng tạo',
    defaultEmoji: '🎨',
    category: AchievementCategory.category,
  ),
  Achievement(
    id: 'creative_15',
    name: 'Nghệ sĩ',
    description: 'Hoàn thành 15 nhiệm vụ sáng tạo',
    defaultEmoji: '✨',
    category: AchievementCategory.category,
  ),

  // ── Level ─────────────────────────────────────────────────
  Achievement(
    id: 'level_2',
    name: 'Level 2',
    description: 'Đạt Level 2',
    defaultEmoji: '🌱',
    category: AchievementCategory.level,
  ),
  Achievement(
    id: 'level_5',
    name: 'Level 5 Explorer',
    description: 'Đạt Level 5',
    defaultEmoji: '🌟',
    category: AchievementCategory.level,
  ),
  Achievement(
    id: 'level_6',
    name: 'Level 6',
    description: 'Đạt Level 6',
    defaultEmoji: '🚀',
    category: AchievementCategory.level,
  ),
  Achievement(
    id: 'level_10',
    name: 'Level 10 Master',
    description: 'Đạt Level 10',
    defaultEmoji: '👑',
    category: AchievementCategory.level,
  ),

  // ── Special ───────────────────────────────────────────────
  Achievement(
    id: 'first_task',
    name: 'Khởi đầu',
    description: 'Hoàn thành nhiệm vụ đầu tiên',
    defaultEmoji: '🏅',
    category: AchievementCategory.special,
  ),
  Achievement(
    id: 'first_lesson',
    name: 'Ham học',
    description: 'Hoàn thành bài học đầu tiên',
    defaultEmoji: '🎒',
    category: AchievementCategory.special,
  ),
];

// Map badge string → achievement id (để link badge cũ với achievement mới)
const badgeToAchievementId = <String, String>{
  '🔥 Chuỗi 3 ngày': 'streak_3',
  '⚡ Chuỗi 7 ngày': 'streak_7',
  '💫 Chuỗi 14 ngày': 'streak_14',
  '🏆 Chuỗi 30 ngày': 'streak_30',
  '🧹 Siêng năng': 'housework_5',
  '🏠 Người giữ nhà': 'housework_15',
  '📚 Mọt sách': 'study_5',
  '🎓 Học giỏi': 'study_15',
  '💪 Năng động': 'health_5',
  '🏅 Sức khỏe vàng': 'health_15',
  '🎨 Tài năng': 'creative_5',
  '✨ Nghệ sĩ': 'creative_15',
  '🚀 Level 6!': 'level_6',
  '🌟 Level 7!': 'level_5',
  '👑 Level 10!': 'level_10',
  '🏅 Khởi đầu': 'first_task',
};
