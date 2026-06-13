import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/memory_postcard.dart';
import 'memory_postcard_preview.dart';

/// Mở màn xem trước album (gộp nhiều kỷ niệm thành 1 ảnh) để chia sẻ.
void _openAlbumPreview(BuildContext context, AppState appState) {
  final memories = appState.memories;
  if (memories.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chưa có kỷ niệm nào để xuất.')),
    );
    return;
  }
  final childName = appState.childName;
  final cards = memories.take(12).map((m) {
    final taskId = m['taskId'] ?? '';
    return MemoryPostcard(
      emoji: m['emoji'] ?? '',
      task: m['task'] ?? '',
      note: m['note'] ?? '',
      date: m['date'] ?? '',
      childName: childName,
      proofImageUrl: m['proofImageUrl'] ?? '',
      proofBytes: taskId.isNotEmpty ? appState.getTaskProofBytes(taskId) : null,
    );
  }).toList();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MemoryPostcardPreview(
        childName: childName,
        pixelRatio: 2.0,
        content: MemoryAlbum(postcards: cards),
      ),
    ),
  );
}

class ParentMemoryLane extends StatelessWidget {
  const ParentMemoryLane({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final memories = appState.memories;

        return Scaffold(
          backgroundColor: AppTheme.surfaceBright,
          appBar: _buildAppBar(() => _openAlbumPreview(context, appState)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MemoryHero(
                  memoriesCount: memories.length,
                  childName: appState.childName,
                  totalCoins: appState.totalCoins,
                  approvedCount: appState.approvedTasks.length,
                  onExport: () => _openAlbumPreview(context, appState),
                ),
                const SizedBox(height: 32),

                if (memories.isEmpty)
                  _EmptyMemory(childName: appState.childName)
                else
                  Stack(
                    children: [
                      // Timeline vertical line
                      Positioned(
                        left: 20,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.primaryFixedDim,
                                AppTheme.secondaryFixed,
                                AppTheme.tertiaryFixed,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Column(
                        children: memories.asMap().entries.map((e) {
                          final m = e.value;
                          final isEven = e.key % 2 == 0;
                          return _MemoryCard(
                            date: m['date']!,
                            task: m['task']!,
                            emoji: m['emoji']!,
                            note: m['note']!,
                            taskId: m['taskId'] ?? '',
                            category: m['category'] ?? '',
                            proofImageUrl: m['proofImageUrl'] ?? '',
                            mood: m['mood'] ?? '',
                            dotColor: isEven ? AppTheme.primaryFixed : AppTheme.secondaryFixed,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(VoidCallback onShare) {
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
        onPressed: () {},
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded, color: AppTheme.vibrantPrimary, size: 24),
          tooltip: 'Chia sẻ',
          onPressed: onShare,
        ),
        IconButton(
          icon: const Icon(Icons.account_circle, color: AppTheme.vibrantPrimary, size: 28),
          onPressed: () {},
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _MemoryHero extends StatelessWidget {
  final int memoriesCount;
  final String childName;
  final int totalCoins;
  final int approvedCount;
  final VoidCallback onExport;

  const _MemoryHero({
    required this.memoriesCount,
    required this.childName,
    required this.totalCoins,
    required this.approvedCount,
    required this.onExport,
  });

  // ignore: unused_element
  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎬', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Hành trình của $childName',
              style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A2E)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatChip(label: 'Kỷ niệm', value: '$memoriesCount', emoji: '📸'),
                _StatChip(label: 'Nhiệm vụ', value: '$approvedCount', emoji: '✅'),
                _StatChip(label: 'Xu tích lũy', value: '$totalCoins', emoji: '🪙'),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Chụp màn hình trang này để lưu lại và chia sẻ hành trình tài chính của $childName với gia đình! 🌱',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF4A4A6A), height: 1.5),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF5B5BD6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Đã hiểu', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryContainer, AppTheme.vibrantPrimary],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.primaryFixed, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.vibrantPrimary.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.photo_camera, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'Kỷ niệm của con',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhìn lại những khoảnh khắc đáng nhớ trong hành trình của con.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: AppTheme.primaryFixedDim,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onExport,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryContainer,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppTheme.vibrantSecondary, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppTheme.vibrantSecondary, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.ios_share, color: AppTheme.onSecondaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    'Tải album kỷ niệm',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSecondaryContainer,
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
}

// ── Memory Card ───────────────────────────────────────────────────────────────

class _MemoryCard extends StatelessWidget {
  final String date;
  final String task;
  final String emoji;
  final String note;
  final String taskId;
  final String category;
  final String proofImageUrl;
  final String mood;
  final Color dotColor;

  const _MemoryCard({
    required this.date,
    required this.task,
    required this.emoji,
    required this.note,
    required this.taskId,
    required this.category,
    required this.proofImageUrl,
    required this.mood,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    // Reactive: auto-rebuilds when proof bytes arrive in AppState
    final proofBytes = taskId.isNotEmpty
        ? context.watch<AppState>().getTaskProofBytes(taskId)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Timeline dot
          Positioned(
            left: 10,
            top: 24,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.surfaceBright, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          // Content card
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.surfaceContainerHigh),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.vibrantPrimary.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      date,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.outline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Task info
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryFixed,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (category.isNotEmpty)
                              Text(
                                category,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppTheme.outline,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (mood.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            mood == 'happy' ? '😊' : mood == 'neutral' ? '😐' : '😔',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.greenLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '✅ Đã duyệt',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Proof image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildProofImage(proofBytes),
                  ),
                  const SizedBox(height: 16),

                  // Parent note bubble
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.surfaceBright, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.vibrantPrimary.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            note,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Export this memory as a postcard image
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final childName = context.read<AppState>().childName;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemoryPostcardPreview(
                              childName: childName,
                              content: MemoryPostcard(
                                emoji: emoji,
                                task: task,
                                note: note,
                                date: date,
                                childName: childName,
                                proofImageUrl: proofImageUrl,
                                proofBytes: proofBytes,
                              ),
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.vibrantPrimary,
                        side: const BorderSide(color: AppTheme.vibrantPrimary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.ios_share, size: 18),
                      label: Text(
                        'Tải ảnh',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      ),
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

  Widget _buildProofImage(dynamic proofBytes) {
    // Priority 1: in-memory bytes — instant, current session
    if (proofBytes != null) {
      return Image.memory(proofBytes, height: 200, width: double.infinity,
        fit: BoxFit.cover, errorBuilder: (_, _, _) => _imagePlaceholder());
    }
    if (proofImageUrl.isNotEmpty) {
      // Priority 2: base64 data URL stored in DB
      if (proofImageUrl.startsWith('data:')) {
        try {
          final bytes = base64Decode(proofImageUrl.split(',').last);
          return Image.memory(bytes, height: 200, width: double.infinity,
            fit: BoxFit.cover, errorBuilder: (_, _, _) => _imagePlaceholder());
        } catch (_) {}
      }
      // Priority 3: HTTPS URL
      return CachedNetworkImage(
        imageUrl: proofImageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, _) => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, _, _) => _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() => Container(
    height: 160,
    width: double.infinity,
    decoration: BoxDecoration(
      color: AppTheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.surfaceContainerHighest, width: 2),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.photo_outlined, size: 36, color: AppTheme.outlineVariant),
        const SizedBox(height: 6),
        Text(
          'Không có ảnh bằng chứng',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.outlineVariant),
        ),
      ],
    ),
  );
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyMemory extends StatelessWidget {
  final String childName;
  const _EmptyMemory({required this.childName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Text('🌸', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'Chưa có kỷ niệm nào',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Duyệt nhiệm vụ đầu tiên cho $childName\nđể tạo kỷ niệm!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;

  const _StatChip({required this.label, required this.value, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF5B5BD6))),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF6B7280))),
      ],
    );
  }
}
