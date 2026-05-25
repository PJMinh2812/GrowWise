import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';

class ChildDreamJar extends StatelessWidget {
  const ChildDreamJar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, child) {
        final dreams = app.dreamItemsList;

        return Scaffold(
          backgroundColor: AppTheme.bg,
          body: SafeArea(
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ước mơ',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                '${app.totalCoins} xu đang có',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppTheme.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add button
                        GestureDetector(
                          onTap: () => _showAddDream(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA855F7).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFA855F7).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.add_rounded, size: 16, color: Color(0xFFA855F7)),
                                const SizedBox(width: 4),
                                Text(
                                  'Thêm ước mơ',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFA855F7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (dreams.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 52)),
                          const SizedBox(height: 14),
                          Text(
                            'Chưa có ước mơ nào',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Thêm ước mơ đầu tiên của con!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppTheme.textHint,
                            ),
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton.icon(
                            onPressed: () => _showAddDream(context),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Thêm ước mơ'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFA855F7),
                              side: const BorderSide(color: Color(0xFFA855F7)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _DreamCard(
                          item: dreams[i],
                          index: i,
                          currentCoins: app.totalCoins,
                          onBuy: () => app.markDreamPurchased(i),
                        )
                            .animate(delay: Duration(milliseconds: i * 35))
                            .fadeIn(duration: 160.ms)
                            .slideY(begin: 0.05, end: 0),
                        childCount: dreams.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddDream(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddDreamSheet(),
    );
  }
}

class _DreamCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final int currentCoins;
  final VoidCallback onBuy;

  const _DreamCard({
    required this.item,
    required this.index,
    required this.currentCoins,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final name = item['name'] as String;
    final price = item['price'] as int;
    final icon = item['icon'] as String;
    final progress = (item['progress'] as double).clamp(0.0, 1.0);
    final isPurchased = item['is_purchased'] as bool? ?? false;
    final canAfford = currentCoins >= price;
    const purple = Color(0xFFA855F7);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPurchased
              ? AppTheme.green.withValues(alpha: 0.4)
              : canAfford
                  ? purple.withValues(alpha: 0.4)
                  : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isPurchased
                      ? AppTheme.greenLight
                      : canAfford
                          ? purple.withValues(alpha: 0.08)
                          : AppTheme.bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isPurchased)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.greenLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '✓ Đã mua',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.green,
                          ),
                        ),
                      )
                    else if (canAfford)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '🎉 Đủ xu rồi!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: purple,
                          ),
                        ),
                      ),
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$price',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: canAfford || isPurchased ? purple : AppTheme.textSecondary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'xu 🪙',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppTheme.border,
                    valueColor: AlwaysStoppedAnimation(
                      isPurchased ? AppTheme.green : purple,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).round()}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isPurchased ? AppTheme.green : purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isPurchased
                ? 'Đã hoàn thành!'
                : '$currentCoins / $price xu  ·  còn ${(price - currentCoins).clamp(0, price)} xu nữa',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppTheme.textHint,
            ),
          ),

          // Buy button
          if (!isPurchased && canAfford) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onBuy,
                style: FilledButton.styleFrom(
                  backgroundColor: purple,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Mua ngay! 🎉',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddDreamSheet extends StatefulWidget {
  const _AddDreamSheet();

  @override
  State<_AddDreamSheet> createState() => _AddDreamSheetState();
}

class _AddDreamSheetState extends State<_AddDreamSheet> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _icon = '⭐';
  bool _loading = false;

  final _icons = ['⭐', '🎮', '🧸', '📱', '🎨', '📚', '🚲', '⚽', '🎵', '🦄', '🏆', '🎁'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Thêm ước mơ mới',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Icon picker
          Text(
            'Chọn biểu tượng',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _icons.map((ic) => GestureDetector(
              onTap: () => setState(() => _icon = ic),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _icon == ic ? const Color(0xFFA855F7).withValues(alpha: 0.1) : AppTheme.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _icon == ic ? const Color(0xFFA855F7) : AppTheme.border,
                    width: _icon == ic ? 2 : 1,
                  ),
                ),
                child: Center(child: Text(ic, style: const TextStyle(fontSize: 22))),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),

          // Name field
          Text('Tên ước mơ', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(hintText: 'VD: Lego, Xe đạp...'),
          ),
          const SizedBox(height: 14),

          // Price field
          Text('Giá xu', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            validator: (v) => Validators.positiveInt(v, 'Giá'),
            decoration: const InputDecoration(hintText: 'VD: 200'),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFA855F7),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      'Thêm ước mơ',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final price = int.tryParse(_priceCtrl.text.trim()) ?? 0;
    if (name.isEmpty || price <= 0) return;

    setState(() => _loading = true);
    await context.read<AppState>().addDream(name, price, _icon);
    if (mounted) Navigator.pop(context);
  }
}
