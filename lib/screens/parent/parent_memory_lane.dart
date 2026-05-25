import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class ParentMemoryLane extends StatelessWidget {
  const ParentMemoryLane({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final memories = appState.memories;

        return Scaffold(
          backgroundColor: AppTheme.surfaceBright,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MemoryHero(
                  onExport: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '🎬 Video kỷ niệm sẽ có trong phiên bản đầy đủ',
                      ),
                    ),
                  ),
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
                          final isEven = e.key % 2 == 0;
                          return _MemoryCard(
                            date: e.value['date']!,
                            task: e.value['task']!,
                            emoji: e.value['emoji']!,
                            note: e.value['note']!,
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

  PreferredSizeWidget _buildAppBar() {
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
              )
            ]
          ),
        ),
      ),
    );
  }
}

class _MemoryHero extends StatelessWidget {
  final VoidCallback onExport;

  const _MemoryHero({required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryContainer,
            AppTheme.vibrantPrimary,
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.primaryFixed, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.vibrantPrimary.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
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
            'Memory Lane',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Relive all the little moments that made big leaps in their journey.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: AppTheme.primaryFixedDim,
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
                  BoxShadow(
                    color: AppTheme.vibrantSecondary,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.movie, color: AppTheme.onSecondaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    'Export Video 2026',
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

class _MemoryCard extends StatelessWidget {
  final String date;
  final String task;
  final String emoji;
  final String note;
  final Color dotColor;

  const _MemoryCard({
    required this.date,
    required this.task,
    required this.emoji,
    required this.note,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The Timeline Dot
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
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                ],
              ),
            ),
          ),
          // Content Card
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
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Chip
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
                  // Task Info
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
                            Text(
                              'Life Skills', // Placeholder category
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: AppTheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Image Placeholder
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.surfaceContainerHighest, width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.photo_size_select_actual_outlined, size: 40, color: AppTheme.outlineVariant),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Speech Bubble Note
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
                        )
                      ],
                    ),
                    child: Text(
                      '"$note"',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: AppTheme.textPrimary,
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
}

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
