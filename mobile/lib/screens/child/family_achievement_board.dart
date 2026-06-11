import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../models/achievement_model.dart';

class FamilyAchievementBoard extends StatefulWidget {
  const FamilyAchievementBoard({super.key});

  @override
  State<FamilyAchievementBoard> createState() =>
      _FamilyAchievementBoardState();
}

class _FamilyAchievementBoardState extends State<FamilyAchievementBoard> {
  int _periodIndex = 0; // 0=Tuần này 1=Tháng này 2=Toàn thời gian

  static const _periods = ['Tuần này', 'Tháng này', 'Toàn thời gian'];

  // Gold/silver/bronze palette
  static const _gold = Color(0xFFFFD700);
  static const _silver = Color(0xFFC0C0C0);
  static const _bronze = Color(0xFFCD7F32);

  static const _podiumBg = Color(0xFFFFF8F3);
  static const _cardBg = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final childName =
        app.childName.isNotEmpty ? app.childName : 'Bé';
    final childXp = _xpForPeriod(app.xp, _periodIndex);

    // Demo siblings — current child always 1st
    final podium = [
      _PodiumEntry(name: childName, xp: childXp, emoji: app.childAvatarEmoji, isCurrentUser: true),
      _PodiumEntry(name: 'Minh', xp: math.max(childXp - 280, 120), emoji: '👦', isCurrentUser: false),
      _PodiumEntry(name: 'An', xp: math.max(childXp - 520, 50), emoji: '👧', isCurrentUser: false),
    ];

    // Recent unlocked badges from AppState
    final unlockedIds = app.badges.toSet();
    final recentBadges = allAchievements
        .where((a) => unlockedIds.contains(a.id))
        .take(4)
        .toList();

    return Theme(
      data: ThemeData(
        fontFamily: 'Nunito Sans',
        scaffoldBackgroundColor: _podiumBg,
      ),
      child: Scaffold(
        backgroundColor: _podiumBg,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildPeriodToggle(),
                    const SizedBox(height: 24),
                    _buildPodium(podium),
                    const SizedBox(height: 28),
                    _buildPersonalStats(app, childXp),
                    const SizedBox(height: 28),
                    _buildRecentAchievements(recentBadges, childName),
                    const SizedBox(height: 24),
                    _buildPrivacyNote(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // XP scales down for shorter periods (demo)
  int _xpForPeriod(int totalXp, int period) {
    if (period == 0) return math.max((totalXp * 0.3).round(), 10); // week
    if (period == 1) return math.max((totalXp * 0.65).round(), 20); // month
    return totalXp; // all-time
  }

  // ── Sliver App Bar ──────────────────────────────────────────────────────────

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: _podiumBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF904D00)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Bảng Vàng Gia Đình 🏆',
        style: GoogleFonts.nunitoSans(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF904D00),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFDDC1AE)),
      ),
    );
  }

  // ── Period Toggle ───────────────────────────────────────────────────────────

  Widget _buildPeriodToggle() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF4E6D5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_periods.length, (i) {
            final active = _periodIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _periodIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF904D00) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _periods[i],
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: active ? Colors.white : const Color(0xFF564334),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Podium ──────────────────────────────────────────────────────────────────

  Widget _buildPodium(List<_PodiumEntry> podium) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF904D00).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place
              Expanded(child: _PodiumColumn(entry: podium[1], rank: 2, color: _silver, height: 88)),
              // 1st place
              Expanded(child: _PodiumColumn(entry: podium[0], rank: 1, color: _gold, height: 120, showCrown: true)),
              // 3rd place
              Expanded(child: _PodiumColumn(entry: podium[2], rank: 3, color: _bronze, height: 56)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Personal Stats ──────────────────────────────────────────────────────────

  Widget _buildPersonalStats(AppState app, int weekXp) {
    final doneTasks = app.approvedTasks.length;
    final streak = app.streakDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiến độ của con',
          style: GoogleFonts.nunitoSans(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF211B10),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                emoji: '⭐',
                label: 'XP kỳ này',
                value: '$weekXp',
                color: const Color(0xFFFFD700),
                bgColor: const Color(0xFFFFFBEB),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                emoji: '✅',
                label: 'Nhiệm vụ xong',
                value: '$doneTasks',
                color: const Color(0xFF006E1C),
                bgColor: const Color(0xFFEBF9F1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                emoji: '🔥',
                label: 'Chuỗi ngày',
                value: '$streak',
                color: const Color(0xFFFF8C00),
                bgColor: const Color(0xFFFFF3E0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // XP progress bar
        _XpProgressBar(
          xp: app.xp,
          xpToNextLevel: app.xpToNextLevel,
          level: app.level,
        ),
      ],
    );
  }

  // ── Recent Achievements ─────────────────────────────────────────────────────

  Widget _buildRecentAchievements(
      List<Achievement> badges, String childName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star_rounded,
                color: Color(0xFF6833EA), size: 22),
            const SizedBox(width: 6),
            Text(
              'Thành Tích Gần Đây',
              style: GoogleFonts.nunitoSans(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF211B10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (badges.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: const Color(0xFFDDC1AE)),
            ),
            child: Column(
              children: [
                const Text('🎖️', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  'Chưa có thành tích nào!\nHãy hoàn thành nhiệm vụ để nhận huy hiệu 💪',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF564334),
                  ),
                ),
              ],
            ),
          )
        else
          ...badges.asMap().entries.map((e) {
            final a = e.value;
            final colors = [
              (const Color(0xFFFF8C00), const Color(0xFFFFF3E0)),
              (const Color(0xFF6833EA), const Color(0xFFEDE9FF)),
              (const Color(0xFF006E1C), const Color(0xFFEBF9F1)),
              (const Color(0xFF904D00), const Color(0xFFFFF8F3)),
            ];
            final (borderColor, bgColor) = colors[e.key % colors.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BadgeCard(
                achievement: a,
                childName: childName,
                borderColor: borderColor,
                bgColor: bgColor,
              ),
            );
          }),
        // Always show a demo badge card if list is short
        if (badges.length < 2)
          _BadgeCard(
            achievement: Achievement(
              id: 'demo_task_1',
              defaultEmoji: '🏠',
              name: 'Người Giúp Việc',
              description: 'Hoàn thành 3 việc nhà',
              category: AchievementCategory.category,
            ),
            childName: childName,
            borderColor: const Color(0xFFFF8C00),
            bgColor: const Color(0xFFFFF3E0),
          ),
      ],
    );
  }

  // ── Privacy Note ────────────────────────────────────────────────────────────

  Widget _buildPrivacyNote() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_rounded,
              size: 14, color: Color(0xFF897362)),
          const SizedBox(width: 4),
          Text(
            'Chỉ gia đình mình thấy',
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF897362),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Podium column ─────────────────────────────────────────────────────────────

class _PodiumEntry {
  final String name;
  final int xp;
  final String emoji;
  final bool isCurrentUser;

  const _PodiumEntry({
    required this.name,
    required this.xp,
    required this.emoji,
    required this.isCurrentUser,
  });
}

class _PodiumColumn extends StatelessWidget {
  final _PodiumEntry entry;
  final int rank;
  final Color color;
  final double height;
  final bool showCrown;

  const _PodiumColumn({
    required this.entry,
    required this.rank,
    required this.color,
    required this.height,
    this.showCrown = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;
    final avatarSize = isFirst ? 72.0 : 56.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showCrown) ...[
          Text('👑', style: TextStyle(fontSize: isFirst ? 28 : 20)),
          const SizedBox(height: 4),
        ],
        // Avatar circle
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: entry.isCurrentUser
                ? const Color(0xFFFFDCC3)
                : const Color(0xFFF4E6D5),
            border: Border.all(color: color, width: 3),
            boxShadow: isFirst
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(entry.emoji,
                style: TextStyle(fontSize: avatarSize * 0.5)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          entry.name,
          style: GoogleFonts.nunitoSans(
            fontSize: isFirst ? 15 : 13,
            fontWeight: FontWeight.w800,
            color: entry.isCurrentUser
                ? const Color(0xFF904D00)
                : const Color(0xFF211B10),
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${entry.xp} XP',
            style: GoogleFonts.nunitoSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color == const Color(0xFFFFD700)
                  ? const Color(0xFF904D00)
                  : color == const Color(0xFFC0C0C0)
                      ? const Color(0xFF564334)
                      : const Color(0xFF7B4A1E),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Podium bar
        Container(
          width: double.infinity,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.6),
                color.withValues(alpha: 0.3),
              ],
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border(top: BorderSide(color: color, width: 2)),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: GoogleFonts.nunitoSans(
                fontSize: isFirst ? 28 : 20,
                fontWeight: FontWeight.w900,
                color: color.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.nunitoSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF564334),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── XP progress bar ───────────────────────────────────────────────────────────

class _XpProgressBar extends StatelessWidget {
  final int xp;
  final int xpToNextLevel;
  final int level;

  const _XpProgressBar({
    required this.xp,
    required this.xpToNextLevel,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final pct = xpToNextLevel > 0
        ? (xp / xpToNextLevel).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDC1AE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF904D00).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $level',
                style: GoogleFonts.nunitoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF904D00),
                ),
              ),
              Text(
                '$xp / $xpToNextLevel XP',
                style: GoogleFonts.nunitoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF564334),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 12,
              backgroundColor: const Color(0xFFEEE0CF),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF8C00)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pct >= 1.0
                ? '🎉 Sẵn sàng lên level tiếp theo!'
                : 'Con đang ở hạng ${_levelTitle(level)} 🌟  Còn ${xpToNextLevel - xp} XP nữa!',
            style: GoogleFonts.nunitoSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF564334),
            ),
          ),
        ],
      ),
    );
  }

  static String _levelTitle(int level) {
    if (level >= 10) return 'Kim Cương';
    if (level >= 7) return 'Bạch Kim';
    if (level >= 5) return 'Vàng';
    if (level >= 3) return 'Bạc';
    return 'Đồng';
  }
}

// ─── Badge card ────────────────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  final Achievement achievement;
  final String childName;
  final Color borderColor;
  final Color bgColor;

  const _BadgeCard({
    required this.achievement,
    required this.childName,
    required this.borderColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(achievement.defaultEmoji,
                  style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF211B10),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$childName đã đạt được!',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF564334),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+100 XP',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: borderColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
