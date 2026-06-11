import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../models/task_model.dart';
import 'child_task_list.dart';
import 'child_jars.dart';
import 'child_dream_jar.dart';
import 'micro_lesson_dialog.dart';
import 'child_learn_screen.dart';
import 'achievement_screen.dart';
import 'family_achievement_board.dart';
import '../login_screen.dart';
import '../ai_chat_screen.dart';
import '../../utils/age_group.dart';

class ChildDashboard extends StatefulWidget {
  const ChildDashboard({super.key});

  @override
  State<ChildDashboard> createState() => _ChildDashboardState();
}

class _ChildDashboardState extends State<ChildDashboard> {
  int _tab = 0;
  final _built = <int>{0};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = context.read<AppState>();
      final name = app.childName.isNotEmpty ? app.childName : 'bé';
      NotificationService.scheduleDailyReminder(childName: name);
      if (app.pendingTasks.isNotEmpty) {
        NotificationService.showPendingTasksReminder(
          childName: name,
          pendingCount: app.pendingTasks.length,
        );
      }
    });
  }

  void _switchTab(int i) {
    setState(() {
      _tab = i;
      _built.add(i);
    });
  }

  Widget _tabWidget(int i) => switch (i) {
    0 => const _HomeTab(),
    1 => const ChildTaskList(),
    2 => const ChildJars(),
    3 => const ChildDreamJar(),
    _ => const ChildLearnScreen(),
  };

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().strings;
    return Theme(
      data: AppTheme.childTheme().copyWith(
        scaffoldBackgroundColor: AppTheme.surfaceBright,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.surfaceBright,
        appBar: _buildAppBar(),
        body: Stack(
          children: List.generate(5, (i) {
            if (!_built.contains(i)) return const SizedBox.shrink();
            return TickerMode(
              enabled: _tab == i,
              child: Offstage(offstage: _tab != i, child: _tabWidget(i)),
            );
          }),
        ),
        bottomNavigationBar: _buildBottomNav(s),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'GrowWise',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppTheme.vibrantPrimary,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.smart_toy, color: AppTheme.vibrantPrimary, size: 28),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiChatScreen()),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle, color: AppTheme.vibrantPrimary, size: 28),
          onPressed: () => _showLogoutSheet(context),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: Container(
          height: 4,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppTheme.vibrantPrimary.withValues(alpha: 0.1),
                blurRadius: 0,
                offset: const Offset(0, 4),
              )
            ]
          ),
        ),
      ),
    );
  }

  void _showLogoutSheet(BuildContext context) {
    final app = context.read<AppState>();
    final s = app.strings;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(
              app.childName.isEmpty ? 'Bé yêu' : app.childName,
              style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Level ${app.level} Explorer',
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.vibrantPrimary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () async {
                Navigator.pop(ctx);
                await app.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFB8B8), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
                    const SizedBox(width: 10),
                    Text(
                      s.signOut,
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFFEF4444)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(dynamic s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_filled, Icons.home_outlined, s.tabHome),
            _buildNavItem(1, Icons.assignment, Icons.assignment_outlined, s.tabTasks),
            _buildNavItem(2, Icons.savings, Icons.savings_outlined, s.tabJars),
            _buildNavItem(3, Icons.stars, Icons.stars_outlined, s.tabDreams),
            _buildNavItem(4, Icons.school, Icons.school_outlined, s.tabLearn),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _tab == index;
    return GestureDetector(
      onTap: () => _switchTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: AppTheme.secondaryContainer,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.onSecondaryContainer,
                    offset: Offset(0, 4),
                  )
                ],
              )
            : const BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? AppTheme.onSecondaryContainer : AppTheme.outlineVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive ? AppTheme.onSecondaryContainer : AppTheme.outlineVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = app.strings;

    // Show micro-lesson dialog when parent approves a task
    if (app.justApprovedTask != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final task = context.read<AppState>().justApprovedTask;
        if (task == null) return;
        context.read<AppState>().consumeJustApprovedTask();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => MicroLessonDialog(
            taskTitle: task.title,
            category: task.category,
            taskId: task.id,
          ),
        );
      });
    }

    // Badge celebration popup
    if (app.pendingNewBadge != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final badge = context.read<AppState>().pendingNewBadge;
        if (badge == null) return;
        context.read<AppState>().consumeNewBadge();
        _showBadgePopup(context, badge);
      });
    }

    final pending = [...app.pendingTasks, ...app.submittedTasks];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        _HeroCard(app: app, s: s)
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: -0.05, curve: Curves.easeOutCubic),
        const SizedBox(height: 14),
        _QuickStats(app: app, pendingCount: pending.length, s: s)
            .animate(delay: 100.ms)
            .fadeIn()
            .slideX(begin: -0.05),
        const SizedBox(height: 20),
        if (app.bondingMessage.isNotEmpty) ...[
          _ParentBubble(
            message: app.bondingMessage,
            parentName: app.parentName.isNotEmpty ? app.parentName : 'Bố/Mẹ',
          ).animate(delay: 150.ms).fadeIn().slideX(begin: -0.08),
          const SizedBox(height: 20),
        ],
        _TasksToday(tasks: pending, s: s)
            .animate(delay: 200.ms)
            .fadeIn()
            .slideY(begin: 0.05),
        const SizedBox(height: 20),
        _JarPreview(app: app, s: s)
            .animate(delay: 300.ms)
            .fadeIn()
            .slideY(begin: 0.05),
        const SizedBox(height: 20),
        _AchievementBoardBanner()
            .animate(delay: 400.ms)
            .fadeIn()
            .slideY(begin: 0.05),
      ],
    );
  }
}

class _AchievementBoardBanner extends StatelessWidget {
  const _AchievementBoardBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FamilyAchievementBoard()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8C00).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bảng Vàng Gia Đình',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Xem thứ hạng & thành tích của gia đình',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}

// ── Hero Card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final AppState app;
  final dynamic s;
  const _HeroCard({required this.app, required this.s});

  @override
  Widget build(BuildContext context) {
    final xpPct = app.xpToNextLevel > 0
        ? (app.xp / app.xpToNextLevel).clamp(0.0, 1.0)
        : 0.0;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⭐ Level ${app.level} Explorer',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      app.childName.isEmpty ? 'Bé yêu' : app.childName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: app.childAge.ageGroup == AgeGroup.young ? 34 : 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white, height: 1,
                      ),
                    ),
                    Text(
                      s.ageDisplay(app.childAge),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          '${app.xp}/${app.xpToNextLevel} XP',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Level ${app.level + 1} →',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10, color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: xpPct),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOutCubic,
                        builder: (ctx, v, _) => FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: v,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ADE80),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Builder(builder: (context) {
                final isYoung = app.childAge.ageGroup == AgeGroup.young;
                final size = isYoung ? 96.0 : 88.0;
                final emojiSize = isYoung ? 58.0 : 50.0;
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      app.childAvatarEmoji.isNotEmpty ? app.childAvatarEmoji : '👦',
                      style: TextStyle(fontSize: emojiSize),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Color(0xFFFBBF24), size: 22),
                const SizedBox(width: 8),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: app.totalCoins),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (ctx, v, _) => Text(
                    '$v ${s.coins}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  s.coinsAvailable,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: Colors.white.withValues(alpha: 0.65),
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

// ── Quick Stats ───────────────────────────────────────────────────────────────

class _QuickStats extends StatelessWidget {
  final AppState app;
  final int pendingCount;
  final dynamic s;
  const _QuickStats({required this.app, required this.pendingCount, required this.s});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatChip('🔥', '${app.streakDays} ${s.daysStr}\n${s.categoryStreak}', const Color(0xFFFF6B6B), const Color(0xFFFFE4E4)),
          const SizedBox(width: 10),
          _StatChip('📋', '$pendingCount ${s.tabTasks}', AppTheme.vibrantPrimary, AppTheme.primaryFixed),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementScreen())),
            child: _StatChip('🏅', '${app.badges.length} ${s.achievementsTitle}', AppTheme.vibrantSecondary, AppTheme.secondaryFixed),
          ),
          const SizedBox(width: 10),
          _StatChip('🏆', '${app.approvedTasks.length} ${s.tabTasks}', AppTheme.vibrantTertiary, AppTheme.tertiaryFixed),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon, label;
  final Color color, bg;
  const _StatChip(this.icon, this.label, this.color, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: color, height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Parent Bubble ─────────────────────────────────────────────────────────────

class _ParentBubble extends StatelessWidget {
  final String message, parentName;
  const _ParentBubble({required this.message, required this.parentName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border.all(color: const Color(0xFFFDE68A), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('💌', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parentName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: const Color(0xFF78350F), height: 1.4,
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

// ── Tasks Today ───────────────────────────────────────────────────────────────

class _TasksToday extends StatelessWidget {
  final List<TaskModel> tasks;
  final dynamic s;
  const _TasksToday({required this.tasks, required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              s.tasksTodaySection,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            if (tasks.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tasks.length} ${s.tabTasks}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.vibrantPrimary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          _EmptyTaskCard()
        else
          ...tasks.asMap().entries.map(
            (e) => _HomeTaskCard(task: e.value)
                .animate(delay: Duration(milliseconds: e.key * 60))
                .fadeIn()
                .slideY(begin: 0.05),
          ),
      ],
    );
  }
}

class _EmptyTaskCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().strings;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.surfaceContainerHigh, width: 2),
      ),
      child: Builder(builder: (context) {
        final isYoung = context.watch<AppState>().childAge.ageGroup == AgeGroup.young;
        return Column(
          children: [
            Text('🎉', style: TextStyle(fontSize: isYoung ? 64.0 : 48.0)),
            const SizedBox(height: 8),
            Text(
              isYoung ? s.noTasksYoung : s.noTasksOlder,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
              ),
            ),
            Text(
              s.noTasksSub,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.outline),
            ),
          ],
        );
      }),
    );
  }
}

class _HomeTaskCard extends StatelessWidget {
  final TaskModel task;
  const _HomeTaskCard({required this.task});

  static const _catStyle = {
    'Việc nhà':   (Color(0xFFE0F2FE), Color(0xFF0284C7)),
    'Học tập':    (Color(0xFFF0FDF4), Color(0xFF16A34A)),
    'Sức khỏe':  (Color(0xFFFFF7ED), Color(0xFFEA580C)),
    'Sáng tạo':  (Color(0xFFFDF4FF), Color(0xFFA21CAF)),
  };

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().strings;
    final style = _catStyle[task.category] ??
        (AppTheme.primaryFixed, AppTheme.vibrantPrimary);
    final isSubmitted = task.status == TaskStatus.submitted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSubmitted
              ? AppTheme.vibrantSecondary.withValues(alpha: 0.4)
              : AppTheme.surfaceContainerHigh,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Builder(builder: (context) {
        final isYoung = context.watch<AppState>().childAge.ageGroup == AgeGroup.young;
        return Row(
        children: [
          Container(
            width: isYoung ? 60.0 : 50.0,
            height: isYoung ? 60.0 : 50.0,
            decoration: BoxDecoration(
              color: style.$1,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text(task.icon, style: TextStyle(fontSize: isYoung ? 32.0 : 26.0))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isSubmitted ? '⏳ ${s.pendingApproval}' : task.category,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: isSubmitted ? AppTheme.vibrantSecondary : AppTheme.outline,
                    fontWeight: isSubmitted ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: style.$1,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${task.coinReward}${s.coins}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w800, color: style.$2,
              ),
            ),
          ),
        ],
        );
      }),
    );
  }
}

// ── Jar Preview ───────────────────────────────────────────────────────────────

class _JarPreview extends StatelessWidget {
  final AppState app;
  final dynamic s;
  const _JarPreview({required this.app, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.surfaceContainerHigh, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                s.jarsSection,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${app.totalCoins} ${s.coins}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.vibrantSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _JarMini('💰', s.jarSpend, app.spendJar, AppTheme.vibrantPrimary, AppTheme.primaryFixed),
              const SizedBox(width: 10),
              _JarMini('🏦', s.jarSave, app.saveJar, AppTheme.vibrantSecondary, AppTheme.secondaryFixed),
              const SizedBox(width: 10),
              _JarMini('🤝', s.jarShare, app.shareJar, const Color(0xFFDC2626), const Color(0xFFFFDAD6)),
            ],
          ),
        ],
      ),
    );
  }
}

class _JarMini extends StatelessWidget {
  final String icon, label;
  final int value;
  final Color color, bg;
  const _JarMini(this.icon, this.label, this.value, this.color, this.bg);

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().strings;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (ctx, v, _) => Text(
                '$v',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20, fontWeight: FontWeight.w900, color: color,
                ),
              ),
            ),
            Text(
              s.coins,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11, color: color.withValues(alpha: 0.7), fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10, color: AppTheme.outline, fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Badge celebration popup (top-level) ───────────────────────────────────────

void _showBadgePopup(BuildContext context, String badge) {
  final parts = badge.split(' ');
  final emoji = parts.first;
  final name = parts.sublist(1).join(' ');
  final s = context.read<AppState>().strings;

  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72))
                .animate()
                .scale(
                  begin: const Offset(0.1, 0.1),
                  duration: 700.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 8),
            Text(
              s.newBadge,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppTheme.vibrantSecondary,
                letterSpacing: 1.2,
              ),
            ).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 4),
            Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
              ),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
            const SizedBox(height: 8),
            Text(
              s.congratsBadge,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textSecondary),
            ).animate(delay: 400.ms).fadeIn(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AchievementScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.vibrantPrimary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      s.viewAllBadges,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600, color: AppTheme.vibrantPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.vibrantPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      s.excellent,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700, color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
