import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../screens/parent/parent_dashboard.dart';
import '../screens/child/child_dashboard.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _goParent(BuildContext context) => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (ctx, a1, a2) => const ParentDashboard(),
          transitionsBuilder: (ctx, a1, a2, child) =>
              FadeTransition(opacity: a1, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );

  void _goChild(BuildContext context) => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (ctx, a1, a2) => const ChildDashboard(),
          transitionsBuilder: (ctx, a1, a2, child) =>
              FadeTransition(opacity: a1, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.surfaceBright,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // Header
              Text(
                'Xin chào! 👋',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),

              const SizedBox(height: 6),

              Text(
                'Bạn là ai?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -1,
                ),
              ).animate(delay: 80.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),

              const SizedBox(height: 8),

              Text(
                'Chọn vai trò để tiếp tục vào ứng dụng',
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
                title: 'Phụ huynh',
                subtitle: 'Giao việc, theo dõi tiến độ\nvà khen thưởng con',
                cardColor: AppTheme.indigoLight,
                borderColor: AppTheme.indigo.withValues(alpha: 0.2),
                accentColor: AppTheme.indigo,
                arrowColor: AppTheme.indigo,
                badges: const [('📋', 'Giao việc'), ('📊', 'Thống kê'), ('🤖', 'AI Bonding')],
                onTap: () => _goParent(context),
              ).animate(delay: 280.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

              const SizedBox(height: 16),

              // Child card
              _RoleCard(
                icon: appState.childAvatarEmoji,
                iconBg: const LinearGradient(
                  colors: [Color(0xFF4ADE80), Color(0xFF1E8F4F)],
                ),
                title: appState.childName.isEmpty ? 'Bé yêu' : appState.childName,
                subtitle: 'Làm nhiệm vụ, tích xu\nvà thực hiện ước mơ!',
                cardColor: AppTheme.greenLight,
                borderColor: AppTheme.green.withValues(alpha: 0.2),
                accentColor: AppTheme.green,
                arrowColor: AppTheme.green,
                badges: const [('🏆', 'Nhiệm vụ'), ('🏦', '3 Hũ'), ('⭐', 'Ước mơ')],
                onTap: () => _goChild(context),
              ).animate(delay: 400.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

              const SizedBox(height: 32),

              // Demo badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline, size: 14, color: AppTheme.textHint),
                      const SizedBox(width: 6),
                      Text(
                        'Demo Mode — Dữ liệu mẫu',
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

class _RoleCardState extends State<_RoleCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
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
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (ctx, child) => Transform.scale(scale: _scale.value, child: child),
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
              // Icon
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: widget.iconBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(widget.icon, style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.badges.map((b) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: widget.accentColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          '${b.$1} ${b.$2}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),

              // Arrow button
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.arrowColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
