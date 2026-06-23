class QuizOption {
  final String text;
  final String emoji;
  const QuizOption({required this.text, required this.emoji});

  factory QuizOption.fromJson(Map<String, dynamic> json) => QuizOption(
        text: json['text'] as String,
        emoji: json['emoji'] as String? ?? '📝',
      );
}

class VideoQuiz {
  final int triggerAt; // seconds when video pauses
  final String question;
  final List<QuizOption> options;
  final int correctIndex;
  final String explanation;
  const VideoQuiz({
    required this.triggerAt,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory VideoQuiz.fromJson(Map<String, dynamic> json, List<QuizOption> options) =>
      VideoQuiz(
        triggerAt: json['trigger_at'] as int,
        question: json['question'] as String,
        correctIndex: json['correct_index'] as int,
        explanation: json['explanation'] as String? ?? '',
        options: options,
      );
}

class StoryPage {
  final String imageUrl;
  final String caption;
  const StoryPage({required this.imageUrl, required this.caption});

  factory StoryPage.fromJson(Map<String, dynamic> json) => StoryPage(
        imageUrl: json['image_url'] as String? ?? '',
        caption: json['caption'] as String? ?? '',
      );
}

class VideoLesson {
  final String id;
  final String title;
  final String description;
  final String? youtubeId; // nullable for story lessons
  final String audience; // 'child' | 'parent'
  final String category;
  final String thumbnailEmoji;
  final int durationSeconds;
  final List<VideoQuiz> quizzes;
  final String lessonType; // 'video' | 'story'
  final List<StoryPage> storyPages;
  final String? thumbnailUrl;

  const VideoLesson({
    required this.id,
    required this.title,
    required this.description,
    this.youtubeId,
    required this.audience,
    required this.category,
    required this.thumbnailEmoji,
    required this.durationSeconds,
    required this.quizzes,
    this.lessonType = 'video',
    this.storyPages = const [],
    this.thumbnailUrl,
  });

  factory VideoLesson.fromJson(Map<String, dynamic> json, List<VideoQuiz> quizzes) {
    final rawPages = json['story_pages'];
    final pages = rawPages is List
        ? rawPages
            .whereType<Map<String, dynamic>>()
            .map(StoryPage.fromJson)
            .toList()
        : <StoryPage>[];
    return VideoLesson(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      youtubeId: json['youtube_id'] as String?,
      audience: json['audience'] as String,
      category: json['category'] as String,
      thumbnailEmoji: json['thumbnail_emoji'] as String? ?? '📚',
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      quizzes: quizzes,
      lessonType: json['lesson_type'] as String? ?? 'video',
      storyPages: pages,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }
}

// ── Demo lesson data ──────────────────────────────────────────────────────────

const demoChildLessons = <VideoLesson>[
  VideoLesson(
    id: 'cl-1',
    title: 'Tiền từ đâu mà có?',
    description:
        'Khám phá cách bố mẹ kiếm tiền và vì sao tiền quan trọng với cuộc sống.',
    youtubeId: 'WRcgRimBac8', // placeholder
    audience: 'child',
    category: 'Tiết kiệm',
    thumbnailEmoji: '💰',
    durationSeconds: 180,
    quizzes: [
      VideoQuiz(
        triggerAt: 40,
        question: 'Tiền dùng để làm gì?',
        options: [
          QuizOption(text: 'Mua đồ ăn và quần áo', emoji: '🛒'),
          QuizOption(text: 'Ném đi cho vui', emoji: '🗑️'),
          QuizOption(text: 'Cất trong túi mãi mãi', emoji: '🎒'),
        ],
        correctIndex: 0,
        explanation:
            'Đúng rồi! Tiền giúp mình mua những thứ cần thiết cho cuộc sống.',
      ),
    ],
  ),
  VideoLesson(
    id: 'cl-2',
    title: 'Hũ tiết kiệm kỳ diệu',
    description: 'Học về 3 hũ tiền — tiêu dùng, tiết kiệm, và chia sẻ.',
    youtubeId: 'QH2-TGUlwu4', // placeholder
    audience: 'child',
    category: 'Tiết kiệm',
    thumbnailEmoji: '🏦',
    durationSeconds: 240,
    quizzes: [
      VideoQuiz(
        triggerAt: 60,
        question: 'Con nên để bao nhiêu % vào hũ tiết kiệm?',
        options: [
          QuizOption(text: '10% – Ít thôi', emoji: '😅'),
          QuizOption(text: '40% – Vừa phải', emoji: '👍'),
          QuizOption(text: '100% – Hết luôn', emoji: '😱'),
        ],
        correctIndex: 1,
        explanation:
            '40% tiết kiệm giúp con mua được ước mơ mà vẫn có tiền tiêu!',
      ),
    ],
  ),
  VideoLesson(
    id: 'cl-3',
    title: 'Muốn và cần — khác nhau thế nào?',
    description:
        'Phân biệt thứ mình muốn và thứ mình thực sự cần để chi tiêu thông minh.',
    youtubeId: 'QH2-TGUlwu4', // placeholder
    audience: 'child',
    category: 'Chi tiêu',
    thumbnailEmoji: '🤔',
    durationSeconds: 200,
    quizzes: [
      VideoQuiz(
        triggerAt: 50,
        question: 'Kẹo và sách, cái nào là "cần"?',
        options: [
          QuizOption(text: 'Kẹo', emoji: '🍬'),
          QuizOption(text: 'Sách', emoji: '📚'),
          QuizOption(text: 'Cả hai đều cần', emoji: '🤷'),
        ],
        correctIndex: 1,
        explanation:
            'Sách giúp con học tốt. Kẹo ngon nhưng chỉ là thứ con "muốn"!',
      ),
    ],
  ),
  VideoLesson(
    id: 'cl-4',
    title: 'Ước mơ và tiết kiệm',
    description:
        'Mỗi đồng xu nhỏ đưa con đến gần ước mơ hơn. Hãy cùng lập kế hoạch!',
    youtubeId: 'QH2-TGUlwu4', // placeholder
    audience: 'child',
    category: 'Ước mơ',
    thumbnailEmoji: '⭐',
    durationSeconds: 220,
    quizzes: [
      VideoQuiz(
        triggerAt: 55,
        question:
            'Con muốn mua đồ chơi 50 xu, đã có 20 xu. Cần tiết kiệm thêm bao nhiêu?',
        options: [
          QuizOption(text: '10 xu', emoji: '🔢'),
          QuizOption(text: '30 xu', emoji: '✅'),
          QuizOption(text: '50 xu', emoji: '❌'),
        ],
        correctIndex: 1,
        explanation: '50 - 20 = 30 xu nữa. Con giỏi toán lắm!',
      ),
    ],
  ),
];

const demoParentLessons = <VideoLesson>[
  VideoLesson(
    id: 'pl-1',
    title: 'Dạy con về 3 hũ tiền',
    description:
        'Phương pháp 3 hũ đơn giản giúp con hiểu tiêu-tiết kiệm-chia sẻ từ nhỏ.',
    youtubeId: 'QH2-TGUlwu4', // placeholder
    audience: 'parent',
    category: 'Phương pháp',
    thumbnailEmoji: '🏦',
    durationSeconds: 300,
    quizzes: [
      VideoQuiz(
        triggerAt: 90,
        question: 'Tỷ lệ tối ưu cho hũ tiết kiệm là bao nhiêu?',
        options: [
          QuizOption(text: '10%', emoji: '📊'),
          QuizOption(text: '40%', emoji: '📈'),
          QuizOption(text: '80%', emoji: '📉'),
        ],
        correctIndex: 1,
        explanation:
            '40% tiết kiệm giúp trẻ hình thành thói quen tốt mà không cảm thấy "bị ép".',
      ),
    ],
  ),
  VideoLesson(
    id: 'pl-2',
    title: 'Tránh "làm vì tiền" — reward đúng cách',
    description:
        'Làm thế nào để khen thưởng con mà không tạo ra động lực tiêu cực?',
    youtubeId: 'QH2-TGUlwu4', // placeholder
    audience: 'parent',
    category: 'Giáo dục',
    thumbnailEmoji: '🎓',
    durationSeconds: 280,
    quizzes: [
      VideoQuiz(
        triggerAt: 80,
        question: 'Khi nào nên khen thưởng bằng tiền?',
        options: [
          QuizOption(text: 'Cho mọi việc con làm', emoji: '💸'),
          QuizOption(text: 'Chỉ những việc có giá trị học hỏi', emoji: '✅'),
          QuizOption(text: 'Không bao giờ', emoji: '🚫'),
        ],
        correctIndex: 1,
        explanation:
            'Thưởng có chọn lọc giúp trẻ hiểu giá trị công việc, không phải chỉ làm để kiếm tiền.',
      ),
    ],
  ),
  VideoLesson(
    id: 'pl-3',
    title: 'Nói chuyện về tiền bạc với con',
    description:
        'Hướng dẫn thực tế cách mở đầu và duy trì cuộc trò chuyện về tài chính.',
    youtubeId: 'QH2-TGUlwu4', // placeholder
    audience: 'parent',
    category: 'Giao tiếp',
    thumbnailEmoji: '💬',
    durationSeconds: 260,
    quizzes: [
      VideoQuiz(
        triggerAt: 70,
        question: 'Độ tuổi tốt nhất để bắt đầu dạy con về tiền?',
        options: [
          QuizOption(text: '3-4 tuổi', emoji: '👶'),
          QuizOption(text: '6-8 tuổi', emoji: '🧒'),
          QuizOption(text: '15 tuổi', emoji: '🧑'),
        ],
        correctIndex: 1,
        explanation:
            '6-8 tuổi là thời điểm vàng — trẻ đã hiểu khái niệm đổi chác và bắt đầu hình thành thói quen.',
      ),
    ],
  ),
];
