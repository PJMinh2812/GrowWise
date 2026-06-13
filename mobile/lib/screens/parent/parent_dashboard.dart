import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/app_state.dart';
import '../../services/emotion_service.dart';
import '../../services/gemini_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../models/task_model.dart';
import 'parent_task_detail.dart';
import 'parent_create_task.dart';
import 'parent_memory_lane.dart';
import 'parent_settings.dart';
import 'parent_learn_screen.dart';
import '../pricing_screen.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _tab = 0;
  final _built = <int>{0};

  void _switchTab(int i) {
    setState(() {
      _tab = i;
      _built.add(i);
    });
  }

  void _goToSettings() => _switchTab(4);

  Widget _tabWidget(int i) => switch (i) {
    0 => _HomeTab(onGoToSettings: _goToSettings),
    1 => const ParentMemoryLane(),
    2 => const ParentLearnScreen(),
    3 => const PricingScreen(),
    _ => const ParentSettings(),
  };

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.parentTheme(),
      child: Scaffold(
        backgroundColor: AppTheme.surfaceBright,
        body: Stack(
          children: List.generate(5, (i) {
            if (!_built.contains(i)) return const SizedBox.shrink();
            return TickerMode(
              enabled: _tab == i,
              child: Offstage(offstage: _tab != i, child: _tabWidget(i)),
            );
          }),
        ),
        floatingActionButton: _tab == 0 ? _buildFAB() : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: _BottomNav(
          current: _tab,
          onTap: _switchTab,
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ParentCreateTask()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.vibrantPrimary,
            borderRadius: BorderRadius.circular(32),
            border: const Border(
              bottom: BorderSide(color: AppTheme.onPrimaryFixedVariant, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.onPrimaryFixedVariant.withValues(alpha: 0.4),
                blurRadius: 0,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Giao việc',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.auto_stories_rounded, Icons.auto_stories_outlined, 'Memories'),
      (Icons.school_rounded, Icons.school_outlined, 'Học'),
      (Icons.workspace_premium_rounded, Icons.workspace_premium_outlined, 'Gói'),
      (Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: tabs.asMap().entries.map((e) {
            final i = e.key;
            final t = e.value;
            final active = current == i;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: active
                    ? BoxDecoration(
                        color: AppTheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(color: AppTheme.onSecondaryContainer, offset: Offset(0, 3)),
                        ],
                      )
                    : const BoxDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      active ? t.$1 : t.$2,
                      size: 22,
                      color: active ? AppTheme.onSecondaryContainer : AppTheme.outlineVariant,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.$3,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                        color: active ? AppTheme.onSecondaryContainer : AppTheme.outlineVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Home Tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  final VoidCallback onGoToSettings;
  const _HomeTab({required this.onGoToSettings});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final topPad = MediaQuery.of(context).padding.top;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 120),
      children: [
        // AppBar row
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              const Icon(Icons.smart_toy, color: AppTheme.vibrantPrimary, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'GrowWise',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.vibrantPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryFixed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.swap_horiz_rounded,
                      color: AppTheme.vibrantPrimary, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onGoToSettings,
                child: const Icon(Icons.account_circle, color: AppTheme.vibrantPrimary, size: 30),
              ),
            ],
          ),
        ),

        // Bonding message bubble
        _WelcomeMessage(message: app.bondingMessage).animate().fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 16),

        // Emotion check-in
        const _EmotionCheckInCard().animate(delay: 60.ms).fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 16),

        // Child profile card
        _ChildProfileCard(app: app).animate(delay: 80.ms).fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 16),

        // Jar summary
        _JarSummaryRow(app: app).animate(delay: 160.ms).fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 16),

        // Weekly summary
        _WeeklySummaryCard(app: app).animate(delay: 220.ms).fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 16),

        // AI Weekly Report
        _AiWeeklyReportCard(app: app).animate(delay: 240.ms).fadeIn().slideY(begin: 0.1),

        // Review Now
        if (app.submittedTasks.isNotEmpty) ...[
          const SizedBox(height: 28),
          _ReviewNowSection(tasks: app.submittedTasks).animate(delay: 240.ms).fadeIn().slideY(begin: 0.1),
        ],

        // Dream Purchase Requests
        if (app.dreamPurchaseRequests.isNotEmpty) ...[
          const SizedBox(height: 28),
          _DreamRequestsSection(requests: app.dreamPurchaseRequests)
              .animate(delay: 260.ms).fadeIn().slideY(begin: 0.1),
        ],

        // All Tasks
        const SizedBox(height: 28),
        _AllTasksSection(app: app).animate(delay: 320.ms).fadeIn().slideY(begin: 0.1),

        // Approved Tasks (for template save)
        if (app.approvedTasks.isNotEmpty) ...[
          const SizedBox(height: 28),
          _ApprovedTasksSection(tasks: app.approvedTasks)
              .animate(delay: 380.ms).fadeIn().slideY(begin: 0.1),
        ],
      ],
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

// ── Emotion Check-In Card ─────────────────────────────────────────────────────

class _EmotionCheckInCard extends StatefulWidget {
  const _EmotionCheckInCard();

  @override
  State<_EmotionCheckInCard> createState() => _EmotionCheckInCardState();
}

class _EmotionCheckInCardState extends State<_EmotionCheckInCard> {
  static const _prefDate   = 'emotion_date';
  static const _prefResult = 'emotion_result';

  EmotionResult? _result;
  bool _loading = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCached();
  }

  Future<void> _loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_prefDate);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (savedDate == today) {
      final raw = prefs.getString(_prefResult);
      if (raw != null) {
        setState(() => _result = EmotionResult.fromJson(jsonDecode(raw)));
      }
    }
  }

  Future<void> _checkIn() async {
    setState(() => _loading = true);
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
        maxWidth: 640,
      );
      if (picked == null) { setState(() => _loading = false); return; }

      final bytes = await picked.readAsBytes();
      final result = await EmotionService.detectEmotion(bytes);

      if (result == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Không nhận diện được khuôn mặt — thử lại với ánh sáng tốt hơn nhé 💡'),
          ));
        }
        setState(() => _loading = false);
        return;
      }

      // Save to prefs
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      await prefs.setString(_prefDate, today);
      await prefs.setString(_prefResult, jsonEncode(result.toJson()));

      // Fire notification
      await NotificationService.showEmotionResult(
        emoji: result.emoji,
        label: result.label,
        advice: result.advice,
      );

      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.border),
      ),
      child: _result != null ? _buildResult() : _buildCheckInButton(),
    );
  }

  Widget _buildCheckInButton() {
    return Column(
      children: [
        Row(
          children: [
            const Text('🎭', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tâm trạng hôm nay',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  Text('AI phân tích cảm xúc qua ảnh selfie',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryFixed,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vì sao nên dùng? 💡',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              ...const [
                '🔍 Nhận biết sớm thay đổi cảm xúc mỗi ngày',
                '💬 Biết lúc nào nên dừng lại, lắng nghe và trò chuyện',
                '🌱 Hiểu cảm xúc để đồng hành cùng con nhẹ nhàng hơn',
              ].map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(line,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5, color: AppTheme.textSecondary, height: 1.4)),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _loading ? null : _checkIn,
            icon: _loading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.camera_front_rounded, size: 18),
            label: Text(
              _loading ? 'AI đang phân tích...' : '📸 Kiểm tra tâm trạng',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.vibrantPrimary,
              side: const BorderSide(color: AppTheme.vibrantPrimary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final r = _result!;
    return Row(
      children: [
        Text(r.emoji, style: const TextStyle(fontSize: 36)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Tâm trạng hôm nay: ',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary)),
                  Text(r.label,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                ],
              ),
              const SizedBox(height: 4),
              Text(r.advice,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

class _WelcomeMessage extends StatelessWidget {
  final String message;
  const _WelcomeMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final text = message.isEmpty ? 'Hôm nay con đã làm rất tốt!' : message;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.primaryFixed,
            borderRadius: BorderRadius.circular(32),
            border: const Border(
              bottom: BorderSide(color: AppTheme.primaryFixedDim, width: 4),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.onPrimaryFixed,
            ),
          ),
        ),
        Positioned(
          bottom: -10,
          left: 48,
          child: Transform.rotate(
            angle: 45 * 3.14159 / 180,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppTheme.primaryFixed,
                boxShadow: const [BoxShadow(color: AppTheme.primaryFixedDim, offset: Offset(2, 2))],
                borderRadius: const BorderRadius.all(Radius.circular(3)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChildProfileCard extends StatelessWidget {
  final AppState app;
  const _ChildProfileCard({required this.app});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.surfaceContainerHigh, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.surfaceBright,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.primaryFixed, width: 2),
              boxShadow: const [BoxShadow(color: AppTheme.primaryFixedDim, offset: Offset(0, 4))],
            ),
            child: Center(
              child: Text(
                app.childAvatarEmoji.isNotEmpty ? app.childAvatarEmoji : '👦',
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      app.childName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${app.childAge} Tuổi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level ${app.level} Explorer',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.vibrantPrimary,
                      ),
                    ),
                    Text(
                      '${app.xp}/${app.xpToNextLevel} XP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: app.xpToNextLevel > 0
                          ? (app.xp / app.xpToNextLevel).clamp(0.0, 1.0)
                          : 0,
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    builder: (ctx, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 10,
                      backgroundColor: AppTheme.surfaceContainerHigh,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.vibrantPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
              border: const Border(
                bottom: BorderSide(color: AppTheme.secondaryFixedDim, width: 4),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: AppTheme.onSecondaryContainer, size: 22),
                Text(
                  '${app.totalCoins}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSecondaryContainer,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Xu',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
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

class _WeeklySummaryCard extends StatelessWidget {
  final AppState app;
  const _WeeklySummaryCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final weekTasks = app.approvedTasks
        .where((t) => t.reviewedAt != null && t.reviewedAt!.isAfter(weekAgo))
        .toList();
    final weekCoins = weekTasks.fold(0, (sum, t) => sum + t.coinReward);
    final fmt = DateFormat('dd/MM');
    final dateRange = '${fmt.format(weekAgo)} – ${fmt.format(DateTime.now())}';

    // Top category this week
    final catCounts = <String, int>{};
    for (final t in weekTasks) {
      catCounts[t.category] = (catCounts[t.category] ?? 0) + 1;
    }
    final topCat = catCounts.isEmpty
        ? null
        : catCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.tertiaryFixed, AppTheme.secondaryFixed],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                'Tuần này',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                dateRange,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _WeekStat('✅', '${weekTasks.length}', 'việc'),
              const SizedBox(width: 12),
              _WeekStat('🪙', '$weekCoins', 'xu'),
              const SizedBox(width: 12),
              _WeekStat('🔥', '${app.streakDays}', 'ngày'),
            ],
          ),
          if (topCat != null) ...[
            const SizedBox(height: 8),
            Text(
              'Nhiều nhất: $topCat',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Con chưa hoàn thành việc nào tuần này',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeekStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _WeekStat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10, color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JarSummaryRow extends StatelessWidget {
  final AppState app;
  const _JarSummaryRow({required this.app});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _JarCard(icon: Icons.shopping_basket_outlined, label: 'Spent', value: app.spendJar, bg: AppTheme.tertiaryFixed, shadow: AppTheme.tertiaryFixedDim, iconColor: AppTheme.vibrantTertiary, labelColor: AppTheme.onTertiaryFixedVariant, valueColor: AppTheme.onTertiaryFixed)),
        const SizedBox(width: 10),
        Expanded(child: _JarCard(icon: Icons.savings_outlined, label: 'Saved', value: app.saveJar, bg: AppTheme.secondaryFixed, shadow: AppTheme.secondaryFixedDim, iconColor: AppTheme.vibrantSecondary, labelColor: AppTheme.onSecondaryFixedVariant, valueColor: AppTheme.onSecondaryFixed)),
        const SizedBox(width: 10),
        Expanded(child: _JarCard(icon: Icons.volunteer_activism_outlined, label: 'Shared', value: app.shareJar, bg: AppTheme.primaryFixed, shadow: AppTheme.primaryFixedDim, iconColor: AppTheme.vibrantPrimary, labelColor: AppTheme.onPrimaryFixedVariant, valueColor: AppTheme.onPrimaryFixed)),
      ],
    );
  }
}

class _JarCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color bg, shadow, iconColor, labelColor, valueColor;

  const _JarCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.bg,
    required this.shadow,
    required this.iconColor,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: AppTheme.surfaceBright, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: labelColor)),
          Text('$value', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: valueColor)),
        ],
      ),
    );
  }
}

class _ReviewNowSection extends StatelessWidget {
  final List<TaskModel> tasks;
  const _ReviewNowSection({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.stars, color: AppTheme.secondaryContainer, size: 26),
            const SizedBox(width: 8),
            Text('Duyệt ngay', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          ],
        ),
        const SizedBox(height: 12),
        ...tasks.map((task) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ReviewTaskCard(task: task),
        )),
      ],
    );
  }
}

class _ReviewTaskCard extends StatelessWidget {
  final TaskModel task;
  const _ReviewTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.surfaceContainerHigh, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.tertiaryFixed,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.tertiaryFixedDim, width: 2),
            ),
            child: Text(task.icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                Text('+${task.coinReward} Xu', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.vibrantPrimary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ParentTaskDetail(task: task))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.vibrantPrimary,
                borderRadius: BorderRadius.circular(20),
                border: const Border(bottom: BorderSide(color: AppTheme.onPrimaryFixedVariant, width: 3)),
              ),
              child: Text('Duyệt', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
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
    final tasks = app.childViewTasks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tất cả nhiệm vụ', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.surfaceContainer, width: 2),
            ),
            child: Center(
              child: Column(
                children: [
                  const Text('📋', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text('Chưa có nhiệm vụ nào', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.outline)),
                  const SizedBox(height: 4),
                  Text('Nhấn "Giao việc" để bắt đầu', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textHint)),
                ],
              ),
            ),
          )
        else
          ...tasks.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TaskListItem(task: e.value)
                .animate(delay: Duration(milliseconds: e.key * 40))
                .fadeIn(duration: 200.ms)
                .slideY(begin: 0.05, end: 0),
          )),
      ],
    );
  }
}

class _ApprovedTasksSection extends StatelessWidget {
  final List<TaskModel> tasks;
  const _ApprovedTasksSection({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '✅ Đã hoàn thành',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.greenLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${tasks.length}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.green,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Nhấn vào task để lưu làm mẫu ⭐',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.outline),
        ),
        const SizedBox(height: 12),
        ...tasks.take(5).toList().asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _TaskListItem(task: e.value)
              .animate(delay: Duration(milliseconds: e.key * 40))
              .fadeIn(duration: 200.ms)
              .slideY(begin: 0.05, end: 0),
        )),
        if (tasks.length > 5)
          Center(
            child: Text(
              '+ ${tasks.length - 5} task khác trong Memory Lane',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.outline),
            ),
          ),
      ],
    );
  }
}

class _DreamRequestsSection extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  const _DreamRequestsSection({required this.requests});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              'Con muốn mua',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.secondaryFixed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${requests.length}',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.onSecondaryFixed),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Con đã tích đủ xu, đang chờ bạn duyệt',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.outline),
        ),
        const SizedBox(height: 12),
        ...requests.map((req) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _DreamRequestCard(req: req),
        )),
      ],
    );
  }
}

class _DreamRequestCard extends StatelessWidget {
  final Map<String, dynamic> req;
  const _DreamRequestCard({required this.req});

  @override
  Widget build(BuildContext context) {
    final dreamId = req['id'] as String;
    final name = req['name'] as String? ?? '';
    final price = req['price'] as int? ?? 0;
    final icon = req['icon'] as String? ?? '⭐';
    final app = context.read<AppState>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryFixed,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.secondaryFixedDim, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceBright,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.secondaryFixedDim, width: 2),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                Text('$price xu', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.vibrantSecondary)),
              ],
            ),
          ),
          // Reject
          GestureDetector(
            onTap: () => app.rejectDreamPurchase(dreamId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFB8B8), width: 2),
              ),
              child: Text('Từ chối', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFEF4444))),
            ),
          ),
          const SizedBox(width: 8),
          // Approve
          GestureDetector(
            onTap: () => app.approveDreamPurchase(dreamId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.vibrantPrimary,
                borderRadius: BorderRadius.circular(16),
                border: const Border(bottom: BorderSide(color: AppTheme.onPrimaryFixedVariant, width: 3)),
              ),
              child: Text('Duyệt', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── AI Weekly Report Card ─────────────────────────────────────────────────────

class _AiWeeklyReportCard extends StatefulWidget {
  final AppState app;
  const _AiWeeklyReportCard({required this.app});

  @override
  State<_AiWeeklyReportCard> createState() => _AiWeeklyReportCardState();
}

class _AiWeeklyReportCardState extends State<_AiWeeklyReportCard> {
  String? _report;
  bool _loading = false;
  bool _expanded = false;

  Future<void> _fetchReport() async {
    if (_loading) return;
    setState(() { _loading = true; _expanded = true; });
    final app = context.read<AppState>();
    final report = await GeminiService.weeklyReport(
      childName: app.childName.isNotEmpty ? app.childName : 'bé',
      totalApproved: app.approvedTasks.length,
      streakDays: app.streakDays,
      categoryTaskCounts: {
        'Học tập': app.approvedTasks.where((t) => t.category == 'Học tập').length,
        'Việc nhà': app.approvedTasks.where((t) => t.category == 'Việc nhà').length,
        'Sức khỏe': app.approvedTasks.where((t) => t.category == 'Sức khỏe').length,
        'Sáng tạo': app.approvedTasks.where((t) => t.category == 'Sáng tạo').length,
      },
      totalCoins: app.totalCoins,
      dreamNames: app.dreamItemsList.map((d) => d['name'] as String? ?? '').toList(),
    );
    if (mounted) setState(() { _report = report; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.tertiaryFixed,
        borderRadius: BorderRadius.circular(20),
        border: const Border(bottom: BorderSide(color: AppTheme.tertiaryFixedDim, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _expanded ? () => setState(() => _expanded = !_expanded) : _fetchReport,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Báo cáo tuần từ Wisy AI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppTheme.onTertiaryFixed,
                      ),
                    ),
                  ),
                  if (_loading)
                    const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.vibrantTertiary))
                  else
                    Icon(_expanded ? Icons.expand_less : Icons.auto_awesome,
                        size: 18, color: AppTheme.vibrantTertiary),
                ],
              ),
            ),
          ),
          if (_expanded && !_loading) ...[
            Divider(height: 1, color: AppTheme.tertiaryFixedDim),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Text(
                _report ?? 'Chưa có báo cáo — nhấn để tạo.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, height: 1.6, color: AppTheme.onTertiaryFixed,
                ),
              ),
            ),
            if (_report != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: GestureDetector(
                  onTap: _fetchReport,
                  child: Text('↺ Làm mới',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: AppTheme.vibrantTertiary,
                      )),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ── Task List Item ────────────────────────────────────────────────────────────

class _TaskListItem extends StatelessWidget {
  final TaskModel task;
  const _TaskListItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ParentTaskDetail(task: task))),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceBright,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppTheme.surfaceContainer, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: AppTheme.primaryFixed, shape: BoxShape.circle),
              child: Text(task.icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  Text(task.category, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.outline)),
                ],
              ),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.outlineVariant, width: 2.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
