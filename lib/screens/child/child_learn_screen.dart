import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/video_lesson_model.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../shared/video_lesson_screen.dart';

class ChildLearnScreen extends StatefulWidget {
  const ChildLearnScreen({super.key});

  @override
  State<ChildLearnScreen> createState() => _ChildLearnScreenState();
}

class _ChildLearnScreenState extends State<ChildLearnScreen> {
  String? _selectedCategory;

  List<String> get _categories {
    final cats = demoChildLessons.map((l) => l.category).toSet().toList();
    return ['Tất cả', ...cats];
  }

  List<VideoLesson> get _filteredLessons {
    if (_selectedCategory == null || _selectedCategory == 'Tất cả') {
      return demoChildLessons;
    }
    return demoChildLessons.where((l) => l.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final completed = app.completedLessonCount;
    final total = demoChildLessons.length;

    return Scaffold(
      backgroundColor: AppTheme.surfaceBright,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Góc học của con 📚',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Progress header
          _ProgressHeader(completed: completed, total: total)
              .animate().fadeIn().slideY(begin: 0.1),
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
            final isCompleted = app.isLessonCompleted(lesson.id);
            return _LessonCard(
              lesson: lesson,
              isCompleted: isCompleted,
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

class _ProgressHeader extends StatelessWidget {
  final int completed;
  final int total;
  const _ProgressHeader({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? completed / total : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryFixed, AppTheme.tertiaryFixed],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$completed/$total bài đã hoàn thành',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.4),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final VideoLesson lesson;
  final bool isCompleted;
  final VoidCallback onTap;
  const _LessonCard({required this.lesson, required this.isCompleted, required this.onTap});

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
          border: Border.all(
            color: isCompleted ? const Color(0xFF22C55E).withValues(alpha: 0.4) : AppTheme.surfaceContainerHigh,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryFixed,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(lesson.thumbnailEmoji, style: const TextStyle(fontSize: 28)),
                  if (isCompleted)
                    Positioned(
                      right: 0, top: 0,
                      child: Container(
                        width: 18, height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E), shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 12, color: Colors.white),
                      ),
                    ),
                ],
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
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _Chip(lesson.category),
                      const SizedBox(width: 6),
                      _Chip('${lesson.durationSeconds ~/ 60} phút'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCompleted ? '✅ Hoàn thành' : '▶ Chưa học',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: isCompleted ? const Color(0xFF16A34A) : AppTheme.vibrantPrimary,
                    ),
                  ),
                ],
              ),
            ),
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
