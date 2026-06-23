import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/gemini_service.dart';

// Stitch "Storybook Finance" palette
const _kPrimary = Color(0xFF630ED4);
const _kPrimaryFixed = Color(0xFFEADDFF);
const _kPrimaryFixedDim = Color(0xFFD2BBFF);
const _kOnPrimaryFixedVariant = Color(0xFF5A00C6);
const _kSecondaryContainer = Color(0xFFFEA619);
const _kOnSecondaryContainer = Color(0xFF684000);
const _kTertiaryFixed = Color(0xFF6BFF8F);
const _kOnTertiaryFixed = Color(0xFF002109);
const _kSurface = Color(0xFFFDF9EE);
const _kSurfaceContainerLowest = Color(0xFFFFFFFF);
const _kSurfaceContainerHigh = Color(0xFFECE8DD);
const _kSurfaceVariant = Color(0xFFE6E2D8);
const _kOnSurface = Color(0xFF1C1C15);
const _kOnSurfaceVariant = Color(0xFF4A4455);
const _kOutline = Color(0xFF7B7487);
const _kGreen = Color(0xFF22C55E);

class ChildDreamJar extends StatelessWidget {
  const ChildDreamJar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, child) {
        final totalCoins = app.totalCoins;
        final hasDreams = app.dreamItemsList.isNotEmpty;

        return Scaffold(
          backgroundColor: _kSurface,
          body: Column(
            children: [
              _buildHeroHeader(totalCoins, context),
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

  Widget _buildHeroHeader(int totalCoins, BuildContext context) {
    final s = context.watch<AppState>().strings;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 24),
      decoration: const BoxDecoration(
        color: _kSurfaceContainerLowest,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Top row: title + add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Jar illustration area
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.dreamsTitle,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _kOnSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _kSecondaryContainer.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: _kSecondaryContainer.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '$totalCoins ${s.coins} ${s.coinsAvailable}',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kOnSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Add button
              GestureDetector(
                onTap: () => _showAddDreamSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _kPrimary,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: const [
                      BoxShadow(color: _kOnPrimaryFixedVariant, offset: Offset(0, 3), blurRadius: 0),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        s.addDream,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Jar illustration
          Container(
            height: 140,
            width: 160,
            decoration: BoxDecoration(
              color: _kPrimaryFixed.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Sparkles
                Positioned(top: 12, left: 20, child: Text('✨', style: TextStyle(fontSize: 16, color: _kSecondaryContainer.withValues(alpha: 0.8)))),
                Positioned(top: 8, right: 24, child: Text('⭐', style: TextStyle(fontSize: 14, color: _kSecondaryContainer.withValues(alpha: 0.9)))),
                Positioned(bottom: 16, left: 16, child: Text('✨', style: TextStyle(fontSize: 12, color: _kPrimary.withValues(alpha: 0.5)))),
                // Jar
                const Text('🏺', style: TextStyle(fontSize: 72)),
                // Coins inside
                Positioned(
                  bottom: 22,
                  child: Text('🪙', style: TextStyle(fontSize: 20, color: _kSecondaryContainer)),
                ),
              ],
            ),
          ).animate().scale(begin: const Offset(0.85, 0.85), duration: 500.ms, curve: Curves.easeOutBack),
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
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: _kSurfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isPurchased
                  ? _kGreen.withValues(alpha: 0.4)
                  : isApproved
                      ? _kGreen.withValues(alpha: 0.6)
                      : _kSurfaceContainerHigh,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                        color: _kPrimaryFixed,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: _kPrimaryFixedDim, offset: Offset(0, 2))],
                      ),
                      child: Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _kOnSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 4),
                              Text(
                                '$price ${s.coins}',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _kOnSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Action button / badge
                    if (isPurchased)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _kTertiaryFixed,
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: const [BoxShadow(color: Color(0xFF005C26), offset: Offset(0, 2))],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 14, color: _kOnTertiaryFixed),
                            const SizedBox(width: 4),
                            Text(
                              'Đã mua',
                              style: GoogleFonts.nunitoSans(fontSize: 11, fontWeight: FontWeight.w700, color: _kOnTertiaryFixed),
                            ),
                          ],
                        ),
                      )
                    else if (isApproved)
                      GestureDetector(
                        onTap: () => _showConfirmPurchaseSheet(context, i, dream),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _kGreen,
                            borderRadius: BorderRadius.circular(99),
                            boxShadow: const [BoxShadow(color: Color(0xFF005C26), offset: Offset(0, 3))],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                s.confirmBtn,
                                style: GoogleFonts.nunitoSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (isRequested)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _kSurfaceContainerHigh,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          s.alreadyRequested,
                          style: GoogleFonts.nunitoSans(fontSize: 11, fontWeight: FontWeight.w600, color: _kOutline),
                        ),
                      )
                    else if (totalCoins >= price)
                      GestureDetector(
                        onTap: () => context.read<AppState>().requestDreamPurchase(i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _kPrimary,
                            borderRadius: BorderRadius.circular(99),
                            boxShadow: const [BoxShadow(color: _kOnPrimaryFixedVariant, offset: Offset(0, 3))],
                          ),
                          child: Text(
                            s.requestPurchase,
                            style: GoogleFonts.nunitoSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 18, color: _kOnSurfaceVariant),
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      itemBuilder: (_) => [
                        if (!isPurchased)
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(children: [
                              const Icon(Icons.edit_outlined, size: 16, color: _kOnSurface),
                              const SizedBox(width: 8),
                              Text('Sửa', style: GoogleFonts.nunitoSans(fontSize: 14, color: _kOnSurface)),
                            ]),
                          ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                            const SizedBox(width: 8),
                            Text('Xóa', style: GoogleFonts.nunitoSans(fontSize: 14, color: Colors.red)),
                          ]),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDreamSheet(context, i, dream);
                        } else if (value == 'delete') {
                          context.read<AppState>().deleteDream(i);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã xóa ước mơ'), duration: Duration(seconds: 2)),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    builder: (ctx, v, child) => LinearProgressIndicator(
                      value: v,
                      minHeight: 10,
                      backgroundColor: _kPrimaryFixed,
                      valueColor: AlwaysStoppedAnimation(
                        isPurchased ? _kGreen : _kPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _kPrimary,
                      ),
                    ),
                    Text(
                      s.dreamProgress((progress * 100).toInt(), totalCoins, price),
                      style: GoogleFonts.nunitoSans(fontSize: 11, color: _kOutline),
                    ),
                  ],
                ),
                if (!isPurchased) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      final app = context.read<AppState>();
                      showDialog(
                        context: context,
                        builder: (_) => _DreamCoachDialog(
                          childName: app.childName.isNotEmpty ? app.childName : 'bạn nhỏ',
                          dreamName: name,
                          dreamPrice: price,
                          currentCoins: totalCoins,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: _kPrimaryFixed,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: _kPrimaryFixedDim),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🤖', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 5),
                          Text(
                            'Wisy gợi ý kế hoạch tiết kiệm',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _kPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ).animate(delay: Duration(milliseconds: 60 * i)).fadeIn().slideY(begin: 0.08);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final s = context.watch<AppState>().strings;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: _kPrimaryFixed.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🏺', style: TextStyle(fontSize: 80)),
              ),
            ).animate().scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 28),
            Text(
              s.noDreamsTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _kOnSurface,
              ),
            ).animate(delay: 100.ms).fadeIn(),
            const SizedBox(height: 8),
            Text(
              s.noDreamsSub,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 15,
                color: _kOutline,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ).animate(delay: 150.ms).fadeIn(),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => _showAddDreamSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: _kPrimary,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: const [
                    BoxShadow(color: _kOnPrimaryFixedVariant, offset: Offset(0, 4), blurRadius: 0),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      s.addDreamBtn,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 200.ms).scale(curve: Curves.easeOutBack),
          ],
        ),
      ),
    );
  }

  void _showAddDreamSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    const icons = ['⭐', '🎮', '📚', '🚲', '🎨', '🧸', '🎯', '🏀', '🎵', '🧱', '✈️', '🏆', '🎪', '🎠', '🌈'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kSurfaceContainerLowest,
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
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _kSurfaceVariant,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    s.addDreamTitle,
                    style: GoogleFonts.nunitoSans(fontSize: 20, fontWeight: FontWeight.w800, color: _kOnSurface),
                  ),
                  const SizedBox(height: 20),
                  Text(s.dreamNameLabel, style: GoogleFonts.nunitoSans(fontSize: 13, fontWeight: FontWeight.w700, color: _kOnSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameCtrl,
                    style: GoogleFonts.nunitoSans(fontSize: 15, color: _kOnSurface),
                    decoration: InputDecoration(
                      hintText: s.dreamNameHint,
                      hintStyle: GoogleFonts.nunitoSans(color: _kOutline),
                      filled: true,
                      fillColor: _kSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: _kSurfaceContainerHigh, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: _kSurfaceContainerHigh, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: _kPrimary, width: 2.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(s.dreamPriceLabel, style: GoogleFonts.nunitoSans(fontSize: 13, fontWeight: FontWeight.w700, color: _kOnSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.nunitoSans(fontSize: 15, color: _kOnSurface),
                    decoration: InputDecoration(
                      hintText: s.dreamPriceHint,
                      hintStyle: GoogleFonts.nunitoSans(color: _kOutline),
                      suffixText: s.coins,
                      suffixStyle: GoogleFonts.nunitoSans(color: _kOnSurfaceVariant, fontWeight: FontWeight.w600),
                      filled: true,
                      fillColor: _kSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: _kSurfaceContainerHigh, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: _kSurfaceContainerHigh, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: _kPrimary, width: 2.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(s.chooseIcon, style: GoogleFonts.nunitoSans(fontSize: 13, fontWeight: FontWeight.w700, color: _kOnSurfaceVariant)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: icons.map((icon) {
                      final isSelected = selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedIcon = icon),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected ? _kPrimaryFixed : _kSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? _kPrimary : _kSurfaceContainerHigh,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: _kPrimary.withValues(alpha: 0.2), blurRadius: 6)]
                                : null,
                          ),
                          child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _kPrimary,
                        shape: const StadiumBorder(),
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
                        style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
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

  void _showEditDreamSheet(BuildContext context, int index, Map<String, dynamic> dream) {
    const icons = ['⭐', '🎮', '📚', '🚲', '🎨', '🧸', '🎯', '🏀', '🎵', '🧱', '✈️', '🏆', '🎪', '🎠', '🌈'];
    final nameCtrl = TextEditingController(text: dream['name'] as String? ?? '');
    final priceCtrl = TextEditingController(text: '${dream['price'] ?? 0}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kSurfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        String selectedIcon = dream['icon'] as String? ?? '⭐';
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
                      width: 48, height: 5,
                      decoration: BoxDecoration(color: _kSurfaceVariant, borderRadius: BorderRadius.circular(99)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Sửa ước mơ',
                    style: GoogleFonts.nunitoSans(fontSize: 20, fontWeight: FontWeight.w800, color: _kOnSurface),
                  ),
                  const SizedBox(height: 20),
                  Text(s.dreamNameLabel, style: GoogleFonts.nunitoSans(fontSize: 13, fontWeight: FontWeight.w700, color: _kOnSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameCtrl,
                    style: GoogleFonts.nunitoSans(fontSize: 15, color: _kOnSurface),
                    decoration: InputDecoration(
                      hintText: s.dreamNameHint,
                      hintStyle: GoogleFonts.nunitoSans(color: _kOutline),
                      filled: true, fillColor: _kSurface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _kSurfaceContainerHigh, width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _kSurfaceContainerHigh, width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _kPrimary, width: 2.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(s.dreamPriceLabel, style: GoogleFonts.nunitoSans(fontSize: 13, fontWeight: FontWeight.w700, color: _kOnSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.nunitoSans(fontSize: 15, color: _kOnSurface),
                    decoration: InputDecoration(
                      hintText: s.dreamPriceHint,
                      hintStyle: GoogleFonts.nunitoSans(color: _kOutline),
                      suffixText: s.coins,
                      suffixStyle: GoogleFonts.nunitoSans(color: _kOnSurfaceVariant, fontWeight: FontWeight.w600),
                      filled: true, fillColor: _kSurface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _kSurfaceContainerHigh, width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _kSurfaceContainerHigh, width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _kPrimary, width: 2.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(s.chooseIcon, style: GoogleFonts.nunitoSans(fontSize: 13, fontWeight: FontWeight.w700, color: _kOnSurfaceVariant)),
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
                            color: isSelected ? _kPrimaryFixed : _kSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isSelected ? _kPrimary : _kSurfaceContainerHigh, width: 2),
                            boxShadow: isSelected ? [BoxShadow(color: _kPrimary.withValues(alpha: 0.2), blurRadius: 6)] : null,
                          ),
                          child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: _kPrimary, shape: const StadiumBorder()),
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final price = int.tryParse(priceCtrl.text.trim()) ?? 0;
                        if (name.isEmpty || price <= 0) return;
                        context.read<AppState>().editDream(index, name, price, selectedIcon);
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Lưu thay đổi',
                        style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
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

  void _showConfirmPurchaseSheet(BuildContext context, int index, Map<String, dynamic> dream) {
    final name = dream['name'] as String? ?? '';
    final icon = dream['icon'] as String? ?? '⭐';
    final price = dream['price'] as int? ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kSurfaceContainerLowest,
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
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(color: _kSurfaceVariant, borderRadius: BorderRadius.circular(99)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: _kPrimaryFixed, borderRadius: BorderRadius.circular(14)),
                        child: Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.confirmBuyTitle,
                              style: GoogleFonts.nunitoSans(fontSize: 18, fontWeight: FontWeight.w800, color: _kOnSurface),
                            ),
                            Text(
                              '$name · $price ${s.coins}',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _kOnSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: proofBytes != null ? _kGreen : _kSurfaceContainerHigh,
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
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: _kPrimaryFixed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add_photo_alternate_outlined, size: 28, color: _kPrimary),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  s.photoOfPurchase,
                                  style: GoogleFonts.nunitoSans(fontSize: 13, fontWeight: FontWeight.w600, color: _kOnSurfaceVariant),
                                ),
                                Text(
                                  s.optional,
                                  style: GoogleFonts.nunitoSans(fontSize: 11, color: _kOutline),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (proofBytes != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => setSheetState(() => proofBytes = null),
                      icon: const Icon(Icons.close, size: 16),
                      label: Text(s.deletePhoto, style: GoogleFonts.nunitoSans(fontSize: 13)),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _kGreen,
                        shape: const StadiumBorder(),
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
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : Text(
                              s.confirmedBuy,
                              style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
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
}

// ── Dream Coach Dialog ────────────────────────────────────────────────────────

class _DreamCoachDialog extends StatefulWidget {
  final String childName;
  final String dreamName;
  final int dreamPrice;
  final int currentCoins;

  const _DreamCoachDialog({
    required this.childName,
    required this.dreamName,
    required this.dreamPrice,
    required this.currentCoins,
  });

  @override
  State<_DreamCoachDialog> createState() => _DreamCoachDialogState();
}

class _DreamCoachDialogState extends State<_DreamCoachDialog> {
  String? _message;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final msg = await GeminiService.dreamCoach(
      childName: widget.childName,
      dreamName: widget.dreamName,
      dreamPrice: widget.dreamPrice,
      currentCoins: widget.currentCoins,
    );
    if (mounted) setState(() { _message = msg; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: _kSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: _kPrimaryFixed, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _kPrimaryFixedDim, width: 2)),
                  child: const Center(child: Text('🤖', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Wisy gợi ý', style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.w800, color: _kOnSurface)),
                      Text('Kế hoạch cho "${widget.dreamName}"',
                          style: GoogleFonts.nunitoSans(fontSize: 12, color: _kOutline),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kPrimaryFixed.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kPrimaryFixedDim),
              ),
              child: _loading
                  ? const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: _kPrimary),
                    ))
                  : Text(
                      _message ?? 'Tiếp tục cố gắng nhé! Mỗi ngày tiết kiệm một ít, ước mơ sẽ thành hiện thực thôi 🌟',
                      style: GoogleFonts.nunitoSans(fontSize: 14, height: 1.6, color: _kOnSurface),
                    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(backgroundColor: _kPrimary, shape: const StadiumBorder()),
                child: Text('Tuyệt, mình hiểu rồi!',
                    style: GoogleFonts.nunitoSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
