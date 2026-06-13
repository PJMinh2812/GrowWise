import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../screens/parent/parent_dashboard.dart';
import '../screens/child/child_dashboard.dart';
import '../widgets/parent_pin_sheet.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _onParentTap(BuildContext context, bool isDemo) async {
    if (isDemo) {
      _goParent(context);
      return;
    }
    final ok = await showParentPinDialog(context);
    if (ok && context.mounted) _goParent(context);
  }

  void _goParent(BuildContext context) => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (ctx, a1, a2) => const ParentDashboard(),
          transitionsBuilder: (ctx, a1, a2, child) =>
              FadeTransition(opacity: a1, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );

  void _navigateToChild(BuildContext context) => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (ctx, a1, a2) => const ChildDashboard(),
          transitionsBuilder: (ctx, a1, a2, child) =>
              FadeTransition(opacity: a1, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );

  Future<void> _onChildTap(BuildContext context, AppState appState) async {
    final children = appState.children;
    Map<String, dynamic>? target;

    if (children.isEmpty) {
      _navigateToChild(context);
      return;
    } else if (children.length == 1) {
      target = children.first;
    } else {
      target = await _showChildPickerSheet(context, appState, children);
    }

    if (target == null || !context.mounted) return;

    final pinHash = target['child_pin_hash'] as String?;
    if (pinHash != null) {
      final ok = await _showChildPinDialog(context, target, pinHash);
      if (!ok || !context.mounted) return;
    }

    await appState.switchChild(target['id'] as String);
    if (context.mounted) _navigateToChild(context);
  }

  Future<Map<String, dynamic>?> _showChildPickerSheet(
    BuildContext context,
    AppState appState,
    List<Map<String, dynamic>> children,
  ) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          24, 16, 24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Chọn hồ sơ con',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...children.map((c) {
              final emoji = c['avatar_emoji'] as String? ?? '👦';
              final name = (c['name'] as String?)?.isNotEmpty == true
                  ? c['name'] as String : 'Con';
              final level = c['level'] as int? ?? 1;
              final hasPin = (c['child_pin_hash'] as String?) != null;
              final isActive = (c['id'] as String) == appState.childId;
              return GestureDetector(
                onTap: () => Navigator.pop(context, c),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primaryFixed : AppTheme.surfaceBright,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isActive
                          ? AppTheme.vibrantPrimary
                          : AppTheme.surfaceContainerHigh,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16, fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              )),
                            Text('Cấp độ $level',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13, color: AppTheme.textHint,
                              )),
                          ],
                        ),
                      ),
                      if (hasPin)
                        const Icon(Icons.lock_outline_rounded,
                          color: AppTheme.textHint, size: 18),
                      if (hasPin) const SizedBox(width: 4),
                      if (isActive)
                        const Icon(Icons.check_circle_rounded,
                          color: AppTheme.vibrantPrimary),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<bool> _showChildPinDialog(
    BuildContext context,
    Map<String, dynamic> child,
    String pinHash,
  ) async {
    final childId = child['id'] as String;
    final childName = (child['name'] as String?)?.isNotEmpty == true
        ? child['name'] as String : 'Con';
    final emoji = child['avatar_emoji'] as String? ?? '👦';

    final controllers = List.generate(4, (_) => TextEditingController());
    final focusNodes = List.generate(4, (_) => FocusNode());
    int attempts = 0;
    DateTime? lockedUntil;
    String errorMsg = '';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final locked = lockedUntil != null &&
              DateTime.now().isBefore(lockedUntil!);

          void onComplete() {
            if (locked) return;
            final pin = controllers.map((c) => c.text).join();
            if (pin.length != 4) return;
            final ok = SupabaseService.verifyChildPinLocal(
              childId, pin, pinHash);
            if (ok) {
              Navigator.pop(ctx, true);
            } else {
              attempts++;
              for (final c in controllers) { c.clear(); }
              focusNodes.first.requestFocus();
              if (attempts >= 3) {
                lockedUntil = DateTime.now().add(
                  const Duration(seconds: 10));
                setState(() =>
                  errorMsg = 'Sai nhiều lần. Thử lại sau 10 giây.');
                Future.delayed(const Duration(seconds: 10), () {
                  if (ctx.mounted) {
                    setState(() {
                      errorMsg = '';
                      lockedUntil = null;
                    });
                  }
                });
              } else {
                setState(() =>
                  errorMsg = 'Mã PIN không đúng. Còn ${3 - attempts} lần.');
              }
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  'Mã PIN của $childName',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nhập 4 chữ số để tiếp tục',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: AppTheme.textHint,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => Container(
                    width: 52, height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceBright,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.surfaceContainerHigh, width: 2)),
                    child: TextField(
                      controller: controllers[i],
                      focusNode: focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      obscureText: true,
                      enabled: !locked,
                      decoration: const InputDecoration(
                        counterText: '', border: InputBorder.none),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22, fontWeight: FontWeight.w800),
                      autofocus: i == 0,
                      onChanged: (v) {
                        if (v.isNotEmpty && i < 3) {
                          focusNodes[i + 1].requestFocus();
                        }
                        if (i == 3 && v.isNotEmpty) onComplete();
                      },
                    ),
                  )),
                ),
                if (errorMsg.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(errorMsg,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, color: Colors.red)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Hủy',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.textHint)),
              ),
              FilledButton(
                onPressed: locked ? null : onComplete,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.vibrantPrimary),
                child: Text('Xác nhận',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );

    for (final c in controllers) { c.dispose(); }
    for (final f in focusNodes) { f.dispose(); }
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.strings;
    final children = appState.children;
    final hasMultiChild = children.length > 1;

    return Scaffold(
      backgroundColor: AppTheme.surfaceBright,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              Text(
                s.hiGreeting,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),

              const SizedBox(height: 6),

              Text(
                s.whoAreYou,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -1,
                ),
              ).animate(delay: 80.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),

              const SizedBox(height: 8),

              Text(
                s.chooseRole,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppTheme.textHint,
                ),
              ).animate(delay: 160.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 40),

              // Parent card
              _RoleCard(
                icon: '👨‍👩‍👧',
                iconBg: const LinearGradient(
                  colors: [Color(0xFF818CF8), Color(0xFF5B5BD6)],
                ),
                title: s.parent,
                subtitle: s.parentSubtitle,
                cardColor: AppTheme.indigoLight,
                borderColor: AppTheme.indigo.withValues(alpha: 0.2),
                accentColor: AppTheme.indigo,
                arrowColor: AppTheme.indigo,
                badges: [
                  ('📋', s.badgeCreateTask),
                  ('📊', s.badgeStats),
                  ('🤖', s.badgeAI),
                ],
                onTap: () => _onParentTap(context, appState.isDemoMode),
              ).animate(delay: 280.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

              const SizedBox(height: 16),

              // Child card
              _RoleCard(
                icon: hasMultiChild ? '👨‍👧‍👦' : appState.childAvatarEmoji,
                iconBg: const LinearGradient(
                  colors: [Color(0xFF4ADE80), Color(0xFF1E8F4F)],
                ),
                title: hasMultiChild
                    ? 'Chọn con'
                    : (appState.childName.isEmpty ? 'Con' : appState.childName),
                subtitle: hasMultiChild
                    ? '${children.length} hồ sơ — chọn hồ sơ để tiếp tục'
                    : s.childSubtitle,
                cardColor: AppTheme.greenLight,
                borderColor: AppTheme.green.withValues(alpha: 0.2),
                accentColor: AppTheme.green,
                arrowColor: AppTheme.green,
                badges: [
                  ('🏆', s.badgeTasks),
                  ('🏦', s.badge3Jars),
                  ('⭐', s.badgeDreams),
                ],
                onTap: () => _onChildTap(context, appState),
              ).animate(delay: 400.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

              const SizedBox(height: 32),

              if (appState.isDemoMode)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline, size: 14,
                          color: AppTheme.textHint),
                        const SizedBox(width: 6),
                        Text(
                          s.demoMode,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.textHint,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 600.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Role Card ─────────────────────────────────────────────────────────────────

class _RoleCard extends StatefulWidget {
  final String icon;
  final LinearGradient iconBg;
  final String title;
  final String subtitle;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;
  final Color arrowColor;
  final List<(String, String)> badges;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
    required this.arrowColor,
    required this.badges,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (ctx, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: widget.borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                  gradient: widget.iconBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.3),
                      blurRadius: 12, offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(widget.icon,
                    style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20, fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: widget.badges.map((b) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: widget.accentColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          '${b.$1} ${b.$2}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: widget.arrowColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
