import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class ChildDreamJar extends StatelessWidget {
  const ChildDreamJar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, child) {
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
    final s = context.watch<AppState>().strings;
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
                s.dreamsTitle,
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
                    '$totalCoins ${s.coins} ${s.coinsAvailable}',
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
            onTap: () => _showAddDreamSheet(context),
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
                    s.addDream,
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
    final appState = context.watch<AppState>();
    final s = appState.strings;
    final pendingRequests = appState.dreamPurchaseRequests;
    final approvedIds = appState.approvedDreamIds;
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
        final dreamId = dream['id'] as String? ?? 'dream-$i';
        final isRequested = pendingRequests.any((r) => r['id'] == dreamId);
        final isApproved = approvedIds.contains(dreamId);
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
                        Text('$price ${s.coins}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.vibrantSecondary)),
                      ],
                    ),
                  ),
                  if (isPurchased)
                    const Icon(Icons.check_circle, color: AppTheme.green, size: 28)
                  else if (isApproved)
                    GestureDetector(
                      onTap: () => _showConfirmPurchaseSheet(context, i, dream),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 15),
                            const SizedBox(width: 4),
                            Text(s.confirmBtn, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                          ],
                        ),
                      ),
                    )
                  else if (isRequested)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(s.alreadyRequested, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.outline)),
                    )
                  else if (totalCoins >= price)
                    GestureDetector(
                      onTap: () => context.read<AppState>().requestDreamPurchase(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.vibrantPrimary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(s.requestPurchase, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
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
                s.dreamProgress((progress * 100).toInt(), totalCoins, price),
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.outline),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmPurchaseSheet(BuildContext context, int index, Map<String, dynamic> dream) {
    final name = dream['name'] as String? ?? '';
    final icon = dream['icon'] as String? ?? '⭐';
    final price = dream['price'] as int? ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        List<int>? proofBytes;
        bool isLoading = false;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final s = ctx.read<AppState>().strings;
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 48, height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppTheme.primaryFixed, borderRadius: BorderRadius.circular(14)),
                        child: Text(icon, style: const TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.confirmBuyTitle, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                            Text('$name · $price ${s.coins}', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.vibrantSecondary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Photo area
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                      if (picked != null) {
                        final bytes = await picked.readAsBytes();
                        setSheetState(() => proofBytes = bytes);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBright,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: proofBytes != null ? AppTheme.green : AppTheme.surfaceContainerHigh,
                          width: 2,
                        ),
                      ),
                      child: proofBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.memory(
                                Uint8List.fromList(proofBytes!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppTheme.outlineVariant),
                                const SizedBox(height: 8),
                                Text(s.photoOfPurchase, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.outline)),
                                Text(s.optional, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textHint)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (proofBytes != null)
                    TextButton.icon(
                      onPressed: () => setSheetState(() => proofBytes = null),
                      icon: const Icon(Icons.close, size: 16),
                      label: Text(s.deletePhoto, style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              setSheetState(() => isLoading = true);
                              await context.read<AppState>().confirmDreamPurchase(
                                index,
                                proofBytes: proofBytes != null ? Uint8List.fromList(proofBytes!) : null,
                              );
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                      child: isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : Text(s.confirmedBuy, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddDreamSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    const icons = ['⭐', '🎮', '📚', '🚲', '🎨', '🧸', '🎯', '🏀', '🎵', '🧱', '✈️', '🏆', '🎪', '🎠', '🌈'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        String selectedIcon = '⭐';
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final s = ctx.read<AppState>().strings;
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48, height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    s.addDreamTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(s.dreamNameLabel, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameCtrl,
                    style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: s.dreamNameHint,
                      hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textHint),
                      filled: true,
                      fillColor: AppTheme.surfaceBright,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(s.dreamPriceLabel, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: s.dreamPriceHint,
                      hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textHint),
                      suffixText: s.coins,
                      filled: true,
                      fillColor: AppTheme.surfaceBright,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(s.chooseIcon, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: icons.map((icon) {
                      final isSelected = selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedIcon = icon),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryFixed : AppTheme.surfaceBright,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppTheme.vibrantPrimary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.vibrantPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final price = int.tryParse(priceCtrl.text.trim()) ?? 0;
                        if (name.isEmpty || price <= 0) return;
                        context.read<AppState>().addDream(name, price, selectedIcon);
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        s.addDreamConfirm,
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final s = context.watch<AppState>().strings;
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
              s.noDreamsTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.noDreamsSub,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.outline,
              ),
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: () => _showAddDreamSheet(context),
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
                      s.addDreamBtn,
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
