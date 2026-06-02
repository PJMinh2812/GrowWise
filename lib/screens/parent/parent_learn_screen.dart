import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/video_lesson_model.dart';
import '../../theme/app_theme.dart';
import '../shared/video_lesson_screen.dart';

class ParentLearnScreen extends StatefulWidget {
  const ParentLearnScreen({super.key});

  @override
  State<ParentLearnScreen> createState() => _ParentLearnScreenState();
}

class _ParentLearnScreenState extends State<ParentLearnScreen> {
  String? _selectedCategory;

  List<String> get _categories {
    final cats = demoParentLessons.map((l) => l.category).toSet().toList();
    return ['Tất cả', ...cats];
  }

  List<VideoLesson> get _filteredLessons {
    if (_selectedCategory == null || _selectedCategory == 'Tất cả') {
      return demoParentLessons;
    }
    return demoParentLessons.where((l) => l.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceBright,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Góc học dành cho bố mẹ 🎓',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Intro card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.surfaceContainerHigh, width: 2),
            ),
            child: Row(
              children: [
                const Text('👨‍👩‍👧', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nuôi dưỡng thói quen tài chính',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Những bài học giúp bạn đồng hành cùng con hiệu quả hơn.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: AppTheme.textSecondary, height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 16),

          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final selected = (_selectedCategory ?? 'Tất cả') == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.vibrantPrimary : AppTheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 16),

          // Lesson list
          ..._filteredLessons.asMap().entries.map((entry) {
            final lesson = entry.value;
            return _ParentLessonCard(
              lesson: lesson,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VideoLessonScreen(lesson: lesson)),
              ),
            ).animate(delay: Duration(milliseconds: 150 + entry.key * 80)).fadeIn().slideY(begin: 0.1);
          }),
        ],
      ),
    );
  }
}

class _ParentLessonCard extends StatelessWidget {
  final VideoLesson lesson;
  final VoidCallback onTap;
  const _ParentLessonCard({required this.lesson, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.surfaceContainerHigh, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.tertiaryFixed,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(lesson.thumbnailEmoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: AppTheme.textSecondary, height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Chip(lesson.category),
                      const SizedBox(width: 6),
                      _Chip('${lesson.durationSeconds ~/ 60} phút'),
                      const SizedBox(width: 6),
                      _Chip('${lesson.quizzes.length} câu hỏi'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.outline),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
      ),
    );
  }
}
