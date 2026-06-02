import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

const _microLessons = {
  'Việc nhà': (
    emoji: '🏠',
    lesson: 'Giúp đỡ việc nhà là cách con nói "Con yêu gia đình mình!"',
    tip: 'Những việc nhỏ hàng ngày tạo nên thói quen lớn.',
  ),
  'Học tập': (
    emoji: '📚',
    lesson: 'Kiến thức là tài sản không ai lấy được của con!',
    tip: 'Mỗi bài học hôm nay là bước tiến cho tương lai.',
  ),
  'Sức khỏe': (
    emoji: '💪',
    lesson: 'Cơ thể khỏe mạnh giúp con học tốt và vui chơi mỗi ngày!',
    tip: 'Sức khỏe là nền tảng của mọi ước mơ.',
  ),
  'Sáng tạo': (
    emoji: '🎨',
    lesson: 'Sáng tạo giúp con nghĩ ra ý tưởng tuyệt vời cho tương lai!',
    tip: 'Mỗi ý tưởng độc đáo đều bắt đầu từ sự tò mò.',
  ),
};

const _defaultLesson = (
  emoji: '⭐',
  lesson: 'Mỗi việc tốt con làm đều có ý nghĩa!',
  tip: 'Tiếp tục phát huy thói quen tốt nhé.',
);

class MicroLessonDialog extends StatefulWidget {
  final String taskTitle;
  final String category;
  final String taskId;

  const MicroLessonDialog({
    super.key,
    required this.taskTitle,
    required this.category,
    required this.taskId,
  });

  @override
  State<MicroLessonDialog> createState() => _MicroLessonDialogState();
}

class _MicroLessonDialogState extends State<MicroLessonDialog> {
  String? _selectedMood;

  @override
  Widget build(BuildContext context) {
    final data = _microLessons[widget.category] ?? _defaultLesson;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(data.emoji, style: const TextStyle(fontSize: 52))
                .animate()
                .scale(
                  begin: const Offset(0.3, 0.3),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 8),
            Text(
              'Hoàn thành rồi! 🎉',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ).animate(delay: 100.ms).fadeIn(),
            const SizedBox(height: 4),
            Text(
              widget.taskTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ).animate(delay: 150.ms).fadeIn(),
            const SizedBox(height: 16),
            // Lesson card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryFixed,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Bài học hôm nay',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onPrimaryFixedVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.lesson,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.tip,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ).animate(delay: 250.ms).slideY(begin: 0.15).fadeIn(),
            const SizedBox(height: 20),
            // Mood rating
            Text(
              'Con cảm thấy thế nào?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ).animate(delay: 350.ms).fadeIn(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MoodButton(
                  emoji: '😊',
                  label: 'Vui',
                  value: 'happy',
                  selected: _selectedMood == 'happy',
                  onTap: () => setState(() => _selectedMood = 'happy'),
                ),
                const SizedBox(width: 12),
                _MoodButton(
                  emoji: '😐',
                  label: 'Bình thường',
                  value: 'neutral',
                  selected: _selectedMood == 'neutral',
                  onTap: () => setState(() => _selectedMood = 'neutral'),
                ),
                const SizedBox(width: 12),
                _MoodButton(
                  emoji: '😔',
                  label: 'Mệt',
                  value: 'sad',
                  selected: _selectedMood == 'sad',
                  onTap: () => setState(() => _selectedMood = 'sad'),
                ),
              ],
            ).animate(delay: 400.ms).fadeIn(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedMood == null
                    ? null
                    : () {
                        if (_selectedMood != null) {
                          context
                              .read<AppState>()
                              .recordTaskMood(widget.taskId, _selectedMood!);
                        }
                        Navigator.pop(context);
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.vibrantPrimary,
                  disabledBackgroundColor: AppTheme.outlineVariant,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Xong! ✓',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _MoodButton({
    required this.emoji,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryFixed : AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.vibrantPrimary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: selected ? AppTheme.vibrantPrimary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
