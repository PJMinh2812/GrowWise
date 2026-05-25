import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class ChildDreamJar extends StatelessWidget {
  const ChildDreamJar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, child) {
        // Assume empty state for dreams as per new design mockup
        final totalCoins = app.totalCoins;
        final hasDreams = app.dreamItemsList.isNotEmpty;

        return Scaffold(
          backgroundColor: AppTheme.surfaceBright,
          body: Column(
            children: [
              _buildHeader(totalCoins, context),
              Expanded(
                child: hasDreams
                    ? _buildDreamList(app.dreamItemsList, totalCoins, context)
                    : _buildEmptyState(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(int totalCoins, BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ước mơ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: AppTheme.vibrantSecondary, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '$totalCoins xu đang có',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              // TODO: Navigate to add dream screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng thêm Ước mơ đang hoàn thiện!')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryFixed,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primaryFixedDim, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, color: AppTheme.vibrantPrimary, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Thêm',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.vibrantPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDreamList(List<Map<String, dynamic>> dreams, int totalCoins, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: dreams.length,
      itemBuilder: (context, i) {
        final dream = dreams[i];
        final name = dream['name'] as String? ?? '';
        final price = dream['price'] as int? ?? 0;
        final icon = dream['icon'] as String? ?? '⭐';
        final progress = (dream['progress'] as double? ?? 0.0).clamp(0.0, 1.0);
        final isPurchased = dream['is_purchased'] as bool? ?? false;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.surfaceContainerHigh, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.primaryFixed, borderRadius: BorderRadius.circular(16)),
                    child: Text(icon, style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                        Text('$price xu', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.vibrantSecondary)),
                      ],
                    ),
                  ),
                  if (isPurchased)
                    const Icon(Icons.check_circle, color: AppTheme.green, size: 28)
                  else if (totalCoins >= price)
                    GestureDetector(
                      onTap: () => context.read<AppState>().markDreamPurchased(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.vibrantPrimary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text('Mua', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (ctx, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 10,
                    backgroundColor: AppTheme.primaryFixed,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.vibrantPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(progress * 100).toInt()}% đã tích lũy ($totalCoins/$price xu)',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.outline),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppTheme.secondaryFixed.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.star, size: 80, color: AppTheme.secondaryContainer),
              ),
            ).animate().scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 32),
            Text(
              'Chưa có ước mơ nào',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm ước mơ đầu tiên của con!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.outline,
              ),
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: () {
                // TODO: Navigate to add dream screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chức năng thêm Ước mơ đang hoàn thiện!')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppTheme.vibrantPrimary, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppTheme.onPrimaryFixedVariant,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: AppTheme.vibrantPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'Thêm ước mơ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.vibrantPrimary,
                      ),
                    ),
                  ],
                ),
              ).animate().scale(curve: Curves.easeOutBack, delay: 200.ms),
            ),
          ],
        ),
      ),
    );
  }
}
