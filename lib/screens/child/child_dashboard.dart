import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import 'child_task_list.dart'; 
import 'child_jars.dart';
import 'child_dream_jar.dart';
import '../login_screen.dart';
import '../ai_chat_screen.dart';

class ChildDashboard extends StatefulWidget {
  const ChildDashboard({super.key});

  @override
  State<ChildDashboard> createState() => _ChildDashboardState();
}

class _ChildDashboardState extends State<ChildDashboard> {
  int _tab = 0;
  final _built = <int>{0};

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
    _ => const ChildDreamJar(),
  };

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.childTheme().copyWith(
        scaffoldBackgroundColor: AppTheme.surfaceBright,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.surfaceBright,
        appBar: _buildAppBar(),
        body: Stack(
          children: List.generate(4, (i) {
            if (!_built.contains(i)) return const SizedBox.shrink();
            return TickerMode(
              enabled: _tab == i,
              child: Offstage(offstage: _tab != i, child: _tabWidget(i)),
            );
          }),
        ),
        bottomNavigationBar: _buildBottomNav(),
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
                      'Đăng xuất',
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

  Widget _buildBottomNav() {
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
            _buildNavItem(0, Icons.home_filled, Icons.home_outlined, 'Trang chủ'),
            _buildNavItem(1, Icons.assignment, Icons.assignment_outlined, 'Nhiệm vụ'),
            _buildNavItem(2, Icons.savings, Icons.savings_outlined, '3 Hũ'),
            _buildNavItem(3, Icons.stars, Icons.stars_outlined, 'Ước mơ'),
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
      children: [
        const _WelcomeMessage().animate().fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 32),
        _ProfileSection(app: app).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 24),
        _SummaryCards(app: app).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 32),
        _AllTasksSection(app: app).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),
      ],
    );
  }
}

class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    final msg = context.watch<AppState>().bondingMessage;
    final displayMsg = msg.isNotEmpty ? msg : 'Hôm nay con đã làm rất tốt! 💛';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryFixed,
            borderRadius: BorderRadius.circular(32),
            border: const Border(
              bottom: BorderSide(color: AppTheme.primaryFixedDim, width: 4),
            ),
          ),
          child: Text(
            displayMsg,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.onPrimaryFixed,
            ),
          ),
        ),
        Positioned(
          bottom: -8,
          left: 40,
          child: Transform.rotate(
            angle: 45 * 3.14159 / 180,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppTheme.primaryFixed,
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryFixedDim, offset: Offset(2, 2)),
                ],
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final AppState app;
  const _ProfileSection({required this.app});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.surfaceContainerHigh, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.vibrantPrimary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.surfaceBright,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppTheme.primaryFixed, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.primaryFixedDim,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Center(
              child: Text(
                app.childAvatarEmoji.isNotEmpty ? app.childAvatarEmoji : '👦',
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      app.childName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${app.childAge} Tuổi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level ${app.level} Explorer',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.vibrantPrimary,
                      ),
                    ),
                    Text(
                      '${app.xp}/${app.xpToNextLevel} XP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // XP Bar
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.surfaceContainerHighest, width: 2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: app.xpToNextLevel > 0 ? (app.xp / app.xpToNextLevel).clamp(0.0, 1.0) : 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.vibrantPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Coins
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer,
              borderRadius: BorderRadius.circular(24),
              border: const Border(
                bottom: BorderSide(color: AppTheme.secondaryFixedDim, width: 4),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: AppTheme.onSecondaryContainer, size: 28),
                Text(
                  '${app.totalCoins}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSecondaryContainer,
                    height: 1.0,
                  ),
                ),
                Text(
                  'Xu',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSecondaryContainer,
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

class _SummaryCards extends StatelessWidget {
  final AppState app;
  const _SummaryCards({required this.app});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BentoCard(
            icon: Icons.shopping_basket,
            label: 'Spent',
            value: app.spendJar,
            bgColor: AppTheme.tertiaryFixed,
            borderColor: AppTheme.tertiaryFixedDim,
            iconColor: AppTheme.vibrantTertiary,
            labelColor: AppTheme.onTertiaryFixedVariant,
            valueColor: AppTheme.onTertiaryFixed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BentoCard(
            icon: Icons.savings,
            label: 'Saved',
            value: app.saveJar,
            bgColor: AppTheme.secondaryFixed,
            borderColor: AppTheme.secondaryFixedDim,
            iconColor: AppTheme.vibrantSecondary,
            labelColor: AppTheme.onSecondaryFixedVariant,
            valueColor: AppTheme.onSecondaryFixed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BentoCard(
            icon: Icons.volunteer_activism,
            label: 'Shared',
            value: app.shareJar,
            bgColor: AppTheme.primaryFixed,
            borderColor: AppTheme.primaryFixedDim,
            iconColor: AppTheme.vibrantPrimary,
            labelColor: AppTheme.onPrimaryFixedVariant,
            valueColor: AppTheme.onPrimaryFixed,
          ),
        ),
      ],
    );
  }
}

class _BentoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final Color labelColor;
  final Color valueColor;

  const _BentoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: borderColor, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceBright,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          Text(
            '$value',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllTasksSection extends StatelessWidget {
  final AppState app;
  const _AllTasksSection({required this.app});

  @override
  Widget build(BuildContext context) {
    // For demo purposes, mapping actual pending tasks or mock ones if empty
    final tasks = app.pendingTasks.isEmpty ? [
      ('Trash', 'Due today', Icons.delete, AppTheme.secondaryFixed, AppTheme.vibrantSecondary),
      ('Watering plants', 'Due tomorrow', Icons.yard, AppTheme.primaryFixed, AppTheme.vibrantPrimary),
      ('Feed the cat', 'Everyday', Icons.pets, AppTheme.tertiaryFixed, AppTheme.vibrantTertiary),
    ] : app.pendingTasks.map((t) => (
      t.title,
      'Due today',
      Icons.task_alt,
      AppTheme.primaryFixed,
      AppTheme.vibrantPrimary
    )).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Tasks',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...tasks.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TaskItem(
            title: t.$1,
            subtitle: t.$2,
            icon: t.$3,
            iconBg: t.$4,
            iconColor: t.$5,
          ),
        )),
      ],
    );
  }
}

class _TaskItem extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _TaskItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  State<_TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<_TaskItem> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBright,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.surfaceContainer, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: widget.iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    decoration: _checked ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.outline,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _checked = !_checked),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _checked ? AppTheme.vibrantPrimary : Colors.transparent,
                border: Border.all(
                  color: _checked ? AppTheme.vibrantPrimary : AppTheme.outlineVariant,
                  width: 3,
                ),
              ),
              child: _checked
                  ? const Icon(Icons.check, color: Colors.white, size: 24)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
