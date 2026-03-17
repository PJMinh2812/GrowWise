import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class ParentMemoryLane extends StatelessWidget {
  const ParentMemoryLane({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final memories = appState.memories;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8EAF6), Color(0xFFC5CAE9)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('📷', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    const Text(
                      'Memory Lane',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nhật ký số - Hành trình trưởng thành của ${appState.childName}',
                      style: const TextStyle(color: AppTheme.textMedium),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '🎬 Tính năng xuất Video kỷ niệm cuối năm sẽ có trong phiên bản đầy đủ',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.movie_creation),
                      label: const Text('Xuất Video Kỷ niệm 2026'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Dòng thời gian',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Timeline
              if (memories.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Chưa có kỷ niệm nào.\nDuyệt nhiệm vụ để tạo kỷ niệm!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMedium),
                    ),
                  ),
                )
              else
                ...memories.map(
                  (m) => _MemoryCard(
                    date: m['date']!,
                    task: m['task']!,
                    emoji: m['emoji']!,
                    note: m['note']!,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final String date;
  final String task;
  final String emoji;
  final String note;

  const _MemoryCard({
    required this.date,
    required this.task,
    required this.emoji,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline dot
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppTheme.parentBlue,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 80,
              color: AppTheme.parentBlue.withValues(alpha: 0.3),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        task,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Placeholder image
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, size: 36, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '💬 $note',
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
