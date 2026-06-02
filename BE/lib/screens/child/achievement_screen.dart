import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/achievement_model.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final unlockedBadges = app.badges.toSet();

    // Group by category
    final grouped = <AchievementCategory, List<Achievement>>{};
    for (final a in allAchievements) {
      grouped.putIfAbsent(a.category, () => []).add(a);
    }

    final categoryLabels = {
      AchievementCategory.streak: ('🔥', 'Chuỗi ngày'),
      AchievementCategory.category: ('📋', 'Theo chủ đề'),
      AchievementCategory.level: ('⭐', 'Cấp độ'),
      AchievementCategory.special: ('🎖️', 'Đặc biệt'),
    };

    return Scaffold(
      backgroundColor: AppTheme.surfaceBright,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text(
          'Bảng thành tích',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // Summary header
          _SummaryHeader(
            earned: _countEarned(unlockedBadges),
            total: allAchievements.length,
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 20),

          // Each category
          ...grouped.entries.map((entry) {
            final (emoji, label) = categoryLabels[entry.key]!;
            return _CategorySection(
              emoji: emoji,
              label: label,
              achievements: entry.value,
              unlockedBadges: unlockedBadges,
              customEmoji: app.customBadgeEmoji,
              onEditEmoji: (a) => _showEmojiPicker(context, a, app),
            ).animate().fadeIn().slideY(begin: 0.1);
          }),
        ],
      ),
    );
  }

  int _countEarned(Set<String> unlockedBadges) {
    return allAchievements.where((a) => _isUnlocked(a, unlockedBadges)).length;
  }

  static bool _isUnlocked(Achievement a, Set<String> badges) {
    // Check if any badge string matches this achievement
    return badgeToAchievementId.entries
        .any((e) => e.value == a.id && badges.any((b) => b.contains(e.key.split(' ').last)));
  }

  void _showEmojiPicker(BuildContext context, Achievement achievement, AppState app) {
    final controller = TextEditingController(
      text: app.customBadgeEmoji[achievement.id] ?? achievement.defaultEmoji,
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Đổi hình ảnh "${achievement.name}"',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nhập emoji mới (1 ký tự):',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 40),
              maxLength: 2,
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                hintText: achievement.defaultEmoji,
                hintStyle: const TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mặc định: ${achievement.defaultEmoji}',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.outline),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              app.setCustomBadgeEmoji(achievement.id, achievement.defaultEmoji);
              Navigator.pop(ctx);
            },
            child: Text('Đặt lại', style: GoogleFonts.plusJakartaSans(color: AppTheme.outline)),
          ),
          FilledButton(
            onPressed: () {
              final emoji = controller.text.trim();
              if (emoji.isNotEmpty) {
                app.setCustomBadgeEmoji(achievement.id, emoji);
              }
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.vibrantPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Lưu', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

bool _isUnlocked(Achievement a, Set<String> badges) {
  return badgeToAchievementId.entries
      .any((e) => e.value == a.id && badges.any((b) => b.contains(e.key.split(' ').last)));
}

// ── Summary Header ────────────────────────────────────────────────────────────

class _SummaryHeader extends StatelessWidget {
  final int earned;
  final int total;
  const _SummaryHeader({required this.earned, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? earned / total : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$earned / $total thành tích',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                    ),
                  ),
                  Text(
                    'đã đạt được',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Section ──────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  final String emoji;
  final String label;
  final List<Achievement> achievements;
  final Set<String> unlockedBadges;
  final Map<String, String> customEmoji;
  final void Function(Achievement) onEditEmoji;

  const _CategorySection({
    required this.emoji,
    required this.label,
    required this.achievements,
    required this.unlockedBadges,
    required this.customEmoji,
    required this.onEditEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: achievements.length,
            itemBuilder: (_, i) {
              final a = achievements[i];
              final unlocked = _isUnlocked(a, unlockedBadges);
              final displayEmoji = customEmoji[a.id] ?? a.defaultEmoji;
              return _AchievementTile(
                achievement: a,
                unlocked: unlocked,
                displayEmoji: displayEmoji,
                onLongPress: unlocked ? () => onEditEmoji(a) : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Achievement Tile ──────────────────────────────────────────────────────────

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;
  final String displayEmoji;
  final VoidCallback? onLongPress;

  const _AchievementTile({
    required this.achievement,
    required this.unlocked,
    required this.displayEmoji,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: () => _showDetail(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: unlocked ? AppTheme.primaryFixed : AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: unlocked ? AppTheme.vibrantPrimary.withValues(alpha: 0.3) : Colors.transparent,
            width: 2,
          ),
          boxShadow: unlocked
              ? [BoxShadow(color: AppTheme.vibrantPrimary.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  displayEmoji,
                  style: TextStyle(
                    fontSize: 36,
                    color: unlocked ? null : Colors.transparent,
                  ),
                ),
                if (!unlocked)
                  const Text('🔒', style: TextStyle(fontSize: 28)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: unlocked ? AppTheme.textPrimary : AppTheme.outline,
              ),
            ),
            if (unlocked && onLongPress != null) ...[
              const SizedBox(height: 2),
              Text(
                'Giữ để đổi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9, color: AppTheme.outline,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              unlocked ? displayEmoji : '🔒',
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 12),
            Text(
              achievement.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14, color: AppTheme.textSecondary, height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: unlocked ? const Color(0xFFF0FDF4) : AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unlocked ? '✅ Đã đạt được' : '🔒 Chưa đạt được',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: unlocked ? const Color(0xFF16A34A) : AppTheme.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
