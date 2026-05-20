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

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero
              _MemoryHero(
                childName: appState.childName,
                onExport: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '🎬 Video kỷ niệm sẽ có trong phiên bản đầy đủ',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Dòng thời gian',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              if (memories.isEmpty)
                _EmptyMemory(childName: appState.childName)
              else
                ...memories.asMap().entries.map(
                  (e) => _MemoryCard(
                    date: e.value['date']!,
                    task: e.value['task']!,
                    emoji: e.value['emoji']!,
                    note: e.value['note']!,
                    isLast: e.key == memories.length - 1,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MemoryHero extends StatelessWidget {
  final String childName;
  final VoidCallback onExport;

  const _MemoryHero({required this.childName, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.gradientIndigo,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.shadowMd(AppTheme.indigo),
      ),
      child: Column(
        children: [
          const Text('📷', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 10),
          Text(
            'Memory Lane',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Hành trình trưởng thành của $childName',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.88),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onExport,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.movie_creation_outlined, size: 18),
            label: Text(
              'Xuất Video Kỷ niệm 2026',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 13,
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

class _MemoryCard extends StatelessWidget {
  final String date;
  final String task;
  final String emoji;
  final String note;
  final bool isLast;

  const _MemoryCard({
    required this.date,
    required this.task,
    required this.emoji,
    required this.note,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                gradient: AppTheme.gradientIndigo,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.indigo.withValues(alpha: 0.4),
                      AppTheme.indigo.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        task,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.indigoLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        date,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.indigo,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 32,
                      color: AppTheme.textHint,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '💬 $note',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
