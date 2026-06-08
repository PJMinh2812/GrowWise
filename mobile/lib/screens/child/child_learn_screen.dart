import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/video_lesson_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/paywall_dialog.dart';
import '../shared/video_lesson_screen.dart';

// Stitch "Storybook Finance" palette
const _kPrimary = Color(0xFF630ED4);
const _kPrimaryFixed = Color(0xFFEADDFF);
const _kSecondaryContainer = Color(0xFFFEA619);
const _kSurface = Color(0xFFFDF9EE);
const _kSurfaceContainerLowest = Color(0xFFFFFFFF);
const _kSurfaceContainerHigh = Color(0xFFECE8DD);
const _kOnSurface = Color(0xFF1C1C15);
const _kOnSurfaceVariant = Color(0xFF4A4455);
const _kOutline = Color(0xFF7B7487);
const _kGreen = Color(0xFF22C55E);
const _kGreenDark = Color(0xFF16A34A);

// Category colors (Stitch spec)
const _kCatSavings = Color(0xFF3B82F6);
const _kCatSavingsBg = Color(0xFFDBEAFE);
const _kCatSpending = Color(0xFFF59E0B);
const _kCatSpendingBg = Color(0xFFFFF7ED);
const _kCatEarning = Color(0xFFEC4899);
const _kCatEarningBg = Color(0xFFFDF2F8);

class ChildLearnScreen extends StatefulWidget {
  const ChildLearnScreen({super.key});

  @override
  State<ChildLearnScreen> createState() => _ChildLearnScreenState();
}

class _ChildLearnScreenState extends State<ChildLearnScreen> {
  String? _selectedCategory;

  List<String?> _categoryKeys(List<VideoLesson> lessons) {
    final cats = lessons.map((l) => l.category).toSet().toList();
    return [null, ...cats];
  }

  List<VideoLesson> _filteredLessons(List<VideoLesson> lessons) {
    if (_selectedCategory == null) return lessons;
    return lessons.where((l) => l.category == _selectedCategory).toList();
  }

  String _categoryEmoji(String? cat) {
    switch (cat) {
      case 'Tiết kiệm': return '🐷';
      case 'Chi tiêu': return '💰';
      case 'Kiếm tiền': return '⭐';
      default: return '📚';
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = app.strings;
    final lessons = app.childLessons;
    final completed = app.completedLessonCount;
    final total = lessons.length;

    return Scaffold(
      backgroundColor: _kSurface,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 100),
        children: [
          // Progress banner
          _ProgressBanner(completed: completed, total: total)
              .animate()
              .fadeIn()
              .slideY(begin: 0.1),
          const SizedBox(height: 20),

          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categoryKeys(lessons).map((cat) {
                final selected = _selectedCategory == cat;
                final emoji = _categoryEmoji(cat);
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? _kPrimary : _kSurfaceContainerLowest,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: selected ? _kPrimary : _kSurfaceContainerHigh,
                        width: 2,
                      ),
                      boxShadow: selected
                          ? [BoxShadow(color: _kPrimary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                          : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          cat ?? s.filterAll,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : _kOnSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 16),

          // Lesson cards
          ..._filteredLessons(lessons).asMap().entries.map((entry) {
            final globalIndex = lessons.indexOf(entry.value);
            final lesson = entry.value;
            final isCompleted = app.isLessonCompleted(lesson.id);
            final isSequentialLocked = entry.key > 0 && !app.isLessonCompleted(lessons[entry.key - 1].id);
            final isPremiumLocked = !app.isPremium && globalIndex >= app.unlockedLessons;
            return _LessonCard(
              lesson: lesson,
              isCompleted: isCompleted,
              isLocked: isSequentialLocked || isPremiumLocked,
              isPremiumLocked: isPremiumLocked,
              onTap: isPremiumLocked
                  ? () => showPaywallDialog(context, feature: PaywallFeature.lesson, childMode: true)
                  : isSequentialLocked
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => VideoLessonScreen(lesson: lesson)),
                          ),
            ).animate(delay: Duration(milliseconds: 120 + entry.key * 80)).fadeIn().slideY(begin: 0.1);
          }),
        ],
      ),
    );
  }
}

// ── Progress Banner ───────────────────────────────────────────────────────────

class _ProgressBanner extends StatelessWidget {
  final int completed;
  final int total;
  const _ProgressBanner({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().strings;
    final pct = total > 0 ? completed / total : 0.0;
    final remaining = total - completed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kPrimaryFixed, const Color(0xFFFFF3CD)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trophy icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _kSecondaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Text('🏆', style: TextStyle(fontSize: 32))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khám Phá Tài Chính',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _kOnSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.lessonProgress(completed, total),
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kOnSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context2, v, child2) => LinearProgressIndicator(
                      value: v,
                      minHeight: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.5),
                      valueColor: const AlwaysStoppedAnimation<Color>(_kPrimary),
                    ),
                  ),
                ),
                if (remaining > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Cố lên! Còn $remaining bài nữa thôi 🎉',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kPrimary,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 6),
                  Text(
                    'Xuất sắc! Đã hoàn thành tất cả 🎊',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kGreen,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Lesson Card ───────────────────────────────────────────────────────────────

class _LessonCard extends StatelessWidget {
  final VideoLesson lesson;
  final bool isCompleted;
  final bool isLocked;
  final bool isPremiumLocked;
  final VoidCallback? onTap;

  const _LessonCard({
    required this.lesson,
    required this.isCompleted,
    required this.isLocked,
    this.isPremiumLocked = false,
    required this.onTap,
  });

  Color _accentColor(String category) {
    switch (category) {
      case 'Tiết kiệm': return _kCatSavings;
      case 'Chi tiêu': return _kCatSpending;
      case 'Kiếm tiền': return _kCatEarning;
      default: return _kPrimary;
    }
  }

  Color _accentBg(String category) {
    switch (category) {
      case 'Tiết kiệm': return _kCatSavingsBg;
      case 'Chi tiêu': return _kCatSpendingBg;
      case 'Kiếm tiền': return _kCatEarningBg;
      default: return _kPrimaryFixed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().strings;
    final accent = _accentColor(lesson.category);
    final accentBg = _accentBg(lesson.category);

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isLocked ? 0.55 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _kSurfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted
                  ? _kGreen.withValues(alpha: 0.3)
                  : _kSurfaceContainerHigh,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.5),
            child: IntrinsicHeight(
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Left accent bar
              Container(width: 4, color: accent),
              // Thumbnail area
              Container(
                width: 72,
                height: 80,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      isPremiumLocked ? '🚀' : isLocked ? '🔒' : lesson.thumbnailEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                    if (isPremiumLocked)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6833EA),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock_rounded, size: 10, color: Colors.white),
                        ),
                      ),
                    if (isCompleted)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: _kGreen, shape: BoxShape.circle),
                          child: const Icon(Icons.check, size: 13, color: Colors.white),
                        ),
                      ),
                    if (!isLocked && !isCompleted)
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                          child: const Icon(Icons.play_arrow_rounded, size: 14, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meta chips
                      Row(
                        children: [
                          _MiniChip(label: lesson.category, color: accent, bgColor: accentBg),
                          const SizedBox(width: 6),
                          _MiniChip(
                            label: '⏱ ${lesson.durationSeconds ~/ 60} phút',
                            color: _kOutline,
                            bgColor: _kSurfaceContainerHigh,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lesson.title,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isLocked ? _kOutline : _kOnSurface,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (isPremiumLocked)
                        Text(
                          'Nâng cấp Premium để xem 🚀',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 11,
                            color: const Color(0xFF6833EA),
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      else if (isLocked)
                        Text(
                          'Hoàn thành bài trước để mở khóa',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 11,
                            color: _kOutline,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else if (isCompleted)
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 14, color: _kGreen),
                            const SizedBox(width: 4),
                            Text(
                              s.statusCompleted,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _kGreenDark,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Bắt đầu →',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const _MiniChip({required this.label, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunitoSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
