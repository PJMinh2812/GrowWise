import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../models/task_model.dart';
import 'parent_task_detail.dart';
import 'parent_create_task.dart';
import 'parent_memory_lane.dart';
import 'parent_settings.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.parentTheme(),
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        body: IndexedStack(
          index: _tab,
          children: const [_HomeTab(), ParentMemoryLane(), ParentSettings()],
        ),
        bottomNavigationBar: _BottomNav(
          current: _tab,
          onTap: (i) => setState(() => _tab = i),
        ),
        floatingActionButton: _tab == 0 ? _Fab() : null,
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ParentCreateTask()),
      ),
      backgroundColor: AppTheme.indigo,
      elevation: 3,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        'Giao việc',
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontSize: 14,
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
      (Icons.auto_stories_rounded, Icons.auto_stories_outlined, 'Ký ức'),
      (Icons.settings_rounded, Icons.settings_outlined, 'Cài đặt'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
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
                        color: active ? AppTheme.indigo : AppTheme.textHint,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.$3,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? AppTheme.indigo : AppTheme.textHint,
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

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Chào buổi sáng';
    if (h < 17) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  String _dateStr() {
    final now = DateTime.now();
    const days = ['CN', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _dateStr(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppTheme.textHint,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${_greeting()}, ${app.parentName.isEmpty ? 'Phụ huynh' : app.parentName}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      // Avatar
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.indigoLight,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            app.parentName.isEmpty ? 'P' : app.parentName[0].toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppTheme.indigo,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 28),

                  // Stats row — numbers as heroes
                  Row(
                    children: [
                      _StatItem(
                        value: '${app.tasks.length}',
                        label: 'Nhiệm vụ',
                        color: AppTheme.indigo,
                      ),
                      _Divider(),
                      _StatItem(
                        value: '${app.submittedTasks.length}',
                        label: 'Chờ duyệt',
                        color: const Color(0xFFF59E0B),
                        highlight: app.submittedTasks.isNotEmpty,
                      ),
                      _Divider(),
                      _StatItem(
                        value: '${app.approvedTasks.length}',
                        label: 'Đã duyệt',
                        color: AppTheme.green,
                      ),
                      _Divider(),
                      _StatItem(
                        value: '${app.totalCoinsRewarded}',
                        label: 'Xu tặng',
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                  // AI bonding message
                  if (app.bondingMessage.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.indigoLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text('🤖', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              app.bondingMessage,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppTheme.indigo,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                  ],
                ],
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Child profile
              _ChildProfile(app: app)
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.08, end: 0),
              const SizedBox(height: 24),

              // Pending approval — urgent section
              if (app.submittedTasks.isNotEmpty) ...[
                _SectionLabel(
                  label: 'Cần duyệt ngay',
                  count: app.submittedTasks.length,
                  urgent: true,
                ),
                const SizedBox(height: 10),
                ...app.submittedTasks.asMap().entries.map((e) =>
                  _TaskRow(task: e.value, index: e.key, urgent: true)
                      .animate(delay: Duration(milliseconds: 100 + e.key * 25))
                      .fadeIn(duration: 160.ms)
                      .slideY(begin: 0.05, end: 0),
                ),
                const SizedBox(height: 24),
              ],

              // All tasks
              _SectionLabel(label: 'Tất cả nhiệm vụ', count: app.tasks.length),
              const SizedBox(height: 10),
              if (app.tasks.isEmpty)
                _Empty()
              else
                ...app.tasks.asMap().entries.map((e) =>
                  _TaskRow(task: e.value, index: e.key)
                      .animate(delay: Duration(milliseconds: 120 + e.key * 25))
                      .fadeIn(duration: 160.ms)
                      .slideY(begin: 0.04, end: 0),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool highlight;
  const _StatItem({required this.value, required this.label, required this.color, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: highlight ? color : AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppTheme.textHint,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppTheme.border);
  }
}

class _ChildProfile extends StatelessWidget {
  final AppState app;
  const _ChildProfile({required this.app});

  @override
  Widget build(BuildContext context) {
    final total = app.totalCoins == 0 ? 1 : app.totalCoins;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                app.childAvatarEmoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.childName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${app.childAge} tuổi  ·  Cấp ${app.level}  ·  ${app.xp}/${app.xpToNextLevel} XP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${app.totalCoins}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFF59E0B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    '🪙 Xu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // XP bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: app.xp / app.xpToNextLevel.clamp(1, 99999),
              minHeight: 4,
              backgroundColor: AppTheme.border,
              valueColor: const AlwaysStoppedAnimation(AppTheme.indigo),
            ),
          ),
          const SizedBox(height: 14),
          // Jar row
          Row(
            children: [
              _JarChip('💰', 'Tiêu', app.spendJar, total, const Color(0xFF3B82F6)),
              const SizedBox(width: 8),
              _JarChip('🏦', 'Tiết', app.saveJar, total, AppTheme.green),
              const SizedBox(width: 8),
              _JarChip('🤝', 'Chia', app.shareJar, total, AppTheme.coral),
            ],
          ),
        ],
      ),
    );
  }
}

class _JarChip extends StatelessWidget {
  final String icon;
  final String label;
  final int value;
  final int total;
  final Color color;
  const _JarChip(this.icon, this.label, this.value, this.total, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              '$icon $label · ${(value / total * 100).round()}%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: AppTheme.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;
  final bool urgent;
  const _SectionLabel({required this.label, required this.count, this.urgent = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (urgent)
          Container(
            width: 8, height: 8,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
          ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: urgent ? const Color(0xFFFEF3C7) : AppTheme.bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: urgent ? const Color(0xFFF59E0B) : AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  final TaskModel task;
  final int index;
  final bool urgent;
  const _TaskRow({required this.task, required this.index, this.urgent = false});

  @override
  Widget build(BuildContext context) {
    final s = _status(task.status);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ParentTaskDetail(task: task)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: s.$2, width: 3),
            top: BorderSide(color: AppTheme.border),
            right: BorderSide(color: AppTheme.border),
            bottom: BorderSide(color: AppTheme.border),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Text(task.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.category,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${task.coinReward} xu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.$1,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: s.$2,
                    ),
                  ),
                ],
              ),
              if (urgent) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.indigo,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Xem',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  (String, Color) _status(TaskStatus s) => switch (s) {
    TaskStatus.pending => ('Chờ làm', AppTheme.textHint),
    TaskStatus.submitted => ('Chờ duyệt', const Color(0xFFF59E0B)),
    TaskStatus.approved => ('Hoàn thành', AppTheme.green),
    TaskStatus.rejected => ('Từ chối', AppTheme.coral),
  };
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text('📋', style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Chưa có nhiệm vụ nào',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Nhấn "Giao việc" để bắt đầu',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
