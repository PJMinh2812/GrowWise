import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class ChildJars extends StatelessWidget {
  const ChildJars({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, child) {
        final totalCoins = app.totalCoins;
        final spend = app.spendJar;
        final save = app.saveJar;
        final share = app.shareJar;

        final spendPct = totalCoins > 0 ? spend / totalCoins : 0.5;
        final savePct = totalCoins > 0 ? save / totalCoins : 0.3;
        final sharePct = totalCoins > 0 ? share / totalCoins : 0.2;

        return Scaffold(
          backgroundColor: AppTheme.surfaceBright,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(totalCoins),
                const SizedBox(height: 32),
                _buildOverviewRings(spend, save, share, spendPct, savePct, sharePct),
                const SizedBox(height: 24),
                _buildAllocationBar(spendPct, savePct, sharePct),
                const SizedBox(height: 32),
                _buildDetailCards(spend, save, share, spendPct, savePct, sharePct),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(int totalCoins) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hũ tiền',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Tổng cộng ',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                color: AppTheme.outline,
              ),
            ),
            Text(
              '$totalCoins xu',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.vibrantPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewRings(int spend, int save, int share, double spendPct, double savePct, double sharePct) {
    return Row(
      children: [
        Expanded(child: _RingCard(title: 'Tiêu dùng', value: spend, pct: spendPct, icon: '💰', color: AppTheme.vibrantPrimary, bgColor: AppTheme.primaryFixed)),
        const SizedBox(width: 12),
        Expanded(child: _RingCard(title: 'Tiết kiệm', value: save, pct: savePct, icon: '🏦', color: AppTheme.vibrantSecondary, bgColor: AppTheme.secondaryFixed)),
        const SizedBox(width: 12),
        Expanded(child: _RingCard(title: 'Sẻ chia', value: share, pct: sharePct, icon: '🤝', color: AppTheme.errorContainer, bgColor: const Color(0xFFFFDAD6))),
      ],
    );
  }

  Widget _buildAllocationBar(double spendPct, double savePct, double sharePct) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.surfaceContainer, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân bổ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 24,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.hardEdge,
            child: Row(
              children: [
                Expanded(flex: (spendPct * 100).toInt(), child: Container(color: AppTheme.vibrantPrimary)),
                Expanded(flex: (savePct * 100).toInt(), child: Container(color: AppTheme.vibrantSecondary)),
                Expanded(flex: (sharePct * 100).toInt(), child: Container(color: const Color(0xFFBA1A1A))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LegendItem(color: AppTheme.vibrantPrimary, label: 'Tiêu dùng'),
              _LegendItem(color: AppTheme.vibrantSecondary, label: 'Tiết kiệm'),
              _LegendItem(color: const Color(0xFFBA1A1A), label: 'Sẻ chia'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCards(int spend, int save, int share, double spendPct, double savePct, double sharePct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _DetailCard(
          title: 'Tiêu dùng',
          value: spend,
          pct: spendPct,
          icon: '💰',
          color: AppTheme.vibrantPrimary,
          bgColor: AppTheme.primaryFixed,
          borderColor: AppTheme.primaryFixedDim,
        ).animate().fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 16),
        _DetailCard(
          title: 'Tiết kiệm',
          value: save,
          pct: savePct,
          icon: '🏦',
          color: AppTheme.vibrantSecondary,
          bgColor: AppTheme.secondaryFixed,
          borderColor: AppTheme.secondaryFixedDim,
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
        const SizedBox(height: 16),
        _DetailCard(
          title: 'Sẻ chia',
          value: share,
          pct: sharePct,
          icon: '🤝',
          color: const Color(0xFFBA1A1A),
          bgColor: const Color(0xFFFFDAD6),
          borderColor: const Color(0xFFFFB4AB),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
      ],
    );
  }
}

class _RingCard extends StatelessWidget {
  final String title;
  final int value;
  final double pct;
  final String icon;
  final Color color;
  final Color bgColor;

  const _RingCard({
    required this.title,
    required this.value,
    required this.pct,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.surfaceContainer, width: 2),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  color: bgColor.withValues(alpha: 0.5),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: pct),
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      color: color,
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 20)),
                      Text(
                        '${(pct * 100).toInt()}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$value xu',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppTheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.outline,
          ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final int value;
  final double pct;
  final String icon;
  final Color color;
  final Color bgColor;
  final Color borderColor;

  const _DetailCard({
    required this.title,
    required this.value,
    required this.pct,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: bgColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: bgColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${(pct * 100).toInt()}% tổng xu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$value',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    'xu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: pct),
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
