import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import 'child_task_list.dart';
import 'child_jars.dart';
import 'child_dream_jar.dart';

class ChildDashboard extends StatefulWidget {
  const ChildDashboard({super.key});

  @override
  State<ChildDashboard> createState() => _ChildDashboardState();
}

class _ChildDashboardState extends State<ChildDashboard> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.childTheme(),
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        body: IndexedStack(
          index: _tab,
          children: const [_HomeTab(), ChildTaskList(), ChildJars(), ChildDreamJar()],
        ),
        bottomNavigationBar: _BottomNav(
          current: _tab,
          onTap: (i) => setState(() => _tab = i),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (Icons.home_rounded, Icons.home_outlined, 'Trang chủ'),
      (Icons.assignment_rounded, Icons.assignment_outlined, 'Nhiệm vụ'),
      (Icons.savings_rounded, Icons.savings_outlined, '3 Hũ'),
      (Icons.star_rounded, Icons.star_outline_rounded, 'Ước mơ'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: tabs.asMap().entries.map((e) {
              final i = e.key;
              final t = e.value;
              final active = current == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? t.$1 : t.$2,
                        size: 22,
                        color: active ? AppTheme.green : AppTheme.textHint,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.$3,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? AppTheme.green : AppTheme.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Home Tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final pending = app.pendingTasks.length;
    final done = app.approvedTasks.length;

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _HeroSection(app: app),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Bonding card
              if (app.bondingMessage.isNotEmpty) ...[
                _BondCard(message: app.bondingMessage)
                    .animate(delay: 200.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
              ],

              // Today summary
              _TodaySummary(pending: pending, done: done)
                  .animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0),
              const SizedBox(height: 20),

              // Jar balances
              _JarRow(app: app)
                  .animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0),
              const SizedBox(height: 20),

              // Badges
              if (app.badges.isNotEmpty) ...[
                _Badges(badges: app.badges)
                    .animate(delay: 500.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 20),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatefulWidget {
  final AppState app;
  const _HeroSection({required this.app});

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _xpCtrl;
  late Animation<double> _xpAnim;

  @override
  void initState() {
    super.initState();
    _xpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    final pct = widget.app.xpToNextLevel > 0
        ? widget.app.xp / widget.app.xpToNextLevel
        : 0.0;
    _xpAnim = Tween<double>(begin: 0, end: pct.clamp(0.0, 1.0)).animate(
      CurvedAnimation(parent: _xpCtrl, curve: Curves.easeOutCubic),
    );
    Future.delayed(500.ms, () { if (mounted) _xpCtrl.forward(); });
  }

  @override
  void dispose() {
    _xpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Top row: greeting + coin badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào,',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppTheme.textHint,
                        ),
                      ),
                      Text(
                        app.childName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
                ),
                // Coin display
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${app.totalCoins}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFF59E0B),
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      '🪙 xu tích lũy',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.textHint,
                      ),
                    ),
                  ],
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
              ],
            ),
            const SizedBox(height: 24),

            // Level + XP arc
            Row(
              children: [
                // XP arc
                SizedBox(
                  width: 80,
                  height: 80,
                  child: AnimatedBuilder(
                    animation: _xpAnim,
                    builder: (ctx, child) => CustomPaint(
                      painter: _ArcPainter(
                        progress: _xpAnim.value,
                        bgColor: AppTheme.border,
                        fgColor: AppTheme.green,
                        strokeWidth: 8,
                      ),
                      child: child,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${app.level}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'LVL',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // XP details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.childAvatarEmoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'XP: ${app.xp} / ${app.xpToNextLevel}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: AnimatedBuilder(
                          animation: _xpAnim,
                          builder: (ctx, snap) => LinearProgressIndicator(
                            value: _xpAnim.value,
                            minHeight: 6,
                            backgroundColor: AppTheme.border,
                            valueColor: const AlwaysStoppedAnimation(AppTheme.green),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cần ${app.xpToNextLevel - app.xp} XP để lên cấp',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ],
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// CustomPainter: arc progress
class _ArcPainter extends CustomPainter {
  final double progress;
  final Color bgColor;
  final Color fgColor;
  final double strokeWidth;

  const _ArcPainter({
    required this.progress,
    required this.bgColor,
    required this.fgColor,
    this.strokeWidth = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    final bg = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..color = fgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle, false, bg,
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle * progress, false, fg,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

class _TodaySummary extends StatelessWidget {
  final int pending;
  final int done;
  const _TodaySummary({required this.pending, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '$pending',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: pending > 0 ? const Color(0xFFF59E0B) : AppTheme.textHint,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Cần hoàn thành',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppTheme.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppTheme.border),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$done',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: done > 0 ? AppTheme.green : AppTheme.textHint,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Đã hoàn thành',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppTheme.textHint,
                    fontWeight: FontWeight.w500,
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

class _JarRow extends StatelessWidget {
  final AppState app;
  const _JarRow({required this.app});

  @override
  Widget build(BuildContext context) {
    final total = app.totalCoins == 0 ? 1 : app.totalCoins;
    final jars = [
      ('💰', 'Tiêu dùng', app.spendJar, const Color(0xFF3B82F6)),
      ('🏦', 'Tiết kiệm', app.saveJar, AppTheme.green),
      ('🤝', 'Sẻ chia', app.shareJar, AppTheme.coral),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hũ tiền',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: jars.asMap().entries.map((e) {
            final j = e.value;
            final pct = (j.$3 / total * 100).round();
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: e.key < 2 ? 10 : 0),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(j.$1, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 6),
                      Text(
                        '${j.$3}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: j.$4,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.textHint,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: j.$3 / total,
                          minHeight: 4,
                          backgroundColor: AppTheme.border,
                          valueColor: AlwaysStoppedAnimation(j.$4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        j.$2,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          color: AppTheme.textHint,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: Duration(milliseconds: e.key * 60)).fadeIn(duration: 300.ms),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BondCard extends StatelessWidget {
  final String message;
  const _BondCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: AppTheme.amber, width: 3),
          top: BorderSide(color: AppTheme.border),
          right: BorderSide(color: AppTheme.border),
          bottom: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Row(
        children: [
          const Text('💛', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bố/Mẹ gửi cho con',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.amber,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    height: 1.4,
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

class _Badges extends StatelessWidget {
  final List<String> badges;
  const _Badges({required this.badges});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Huy hiệu',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: badges.asMap().entries.map((e) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              e.value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ).animate(delay: Duration(milliseconds: e.key * 50)).fadeIn(duration: 300.ms)).toList(),
        ),
      ],
    );
  }
}
