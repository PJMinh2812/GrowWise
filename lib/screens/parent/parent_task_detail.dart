import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../models/task_model.dart';

class ParentTaskDetail extends StatelessWidget {
  final TaskModel task;

  const ParentTaskDetail({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.parentTheme(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
          title: Text(
            task.title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero task card
              _TaskHero(task: task),
              const SizedBox(height: 24),

              // Description
              if (task.description.isNotEmpty) ...[
                Text(
                  'Mô tả nhiệm vụ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Text(
                    task.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      height: 1.6,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Status-specific content
              if (task.status == TaskStatus.submitted) ...[
                _ProofSection(),
                const SizedBox(height: 20),
                _PraiseSection(),
                const SizedBox(height: 28),
                _ActionButtons(task: task),
              ],

              if (task.status == TaskStatus.approved)
                _StatusBanner(
                  emoji: '✅',
                  title: 'Đã duyệt!',
                  subtitle: 'Xu đã được cộng vào tài khoản của con',
                  color: AppTheme.green,
                  bgColor: AppTheme.greenLight,
                ),

              if (task.status == TaskStatus.rejected)
                _StatusBanner(
                  emoji: '❌',
                  title: 'Đã từ chối',
                  subtitle: 'Con cần làm lại và nộp lần nữa',
                  color: const Color(0xFFEF4444),
                  bgColor: const Color(0xFFFEF2F2),
                ),

              if (task.status == TaskStatus.pending)
                _StatusBanner(
                  emoji: '⏳',
                  title: 'Chờ con hoàn thành',
                  subtitle: 'Nhiệm vụ đã được giao, chờ con nộp bằng chứng',
                  color: AppTheme.textSecondary,
                  bgColor: AppTheme.bg,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskHero extends StatelessWidget {
  final TaskModel task;
  const _TaskHero({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.gradientIndigo,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.shadowMd(AppTheme.indigo),
      ),
      child: Column(
        children: [
          Text(task.icon, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            task.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '🪙 ${task.coinReward} Xu',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProofSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppTheme.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Bằng chứng từ con',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_outlined,
                  size: 44,
                  color: AppTheme.textHint,
                ),
                const SizedBox(height: 8),
                Text(
                  '📸 Ảnh con chụp khi hoàn thành',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppTheme.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Đã nộp hôm nay lúc 15:30',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _PraiseSection extends StatefulWidget {
  @override
  State<_PraiseSection> createState() => _PraiseSectionState();
}

class _PraiseSectionState extends State<_PraiseSection> {
  final _ctrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childName = context.read<AppState>().childName;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.indigoLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💬 Gửi lời khen cho con',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lời khen sẽ xuất hiện trên màn hình của con',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          if (_sent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.greenLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '✅ Đã gửi lời khen!',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            TextField(
              controller: _ctrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'VD: Con đã làm rất tốt! Bố/Mẹ rất tự hào!',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final msg = _ctrl.text.trim();
                  if (msg.isEmpty) return;
                  context.read<AppState>().addBondingMessage(msg);
                  setState(() => _sent = true);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.send_rounded, size: 16),
                label: Text(
                  'Gửi lời khen cho $childName',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final TaskModel task;
  const _ActionButtons({required this.task});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showRejectDialog(context),
            icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444)),
            label: Text(
              'Từ chối',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFEF4444)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppTheme.gradientGreen,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.shadowMd(AppTheme.green),
            ),
            child: FilledButton.icon(
              onPressed: () => _showApprovalDialog(context),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.check_rounded, color: Colors.white),
              label: Text(
                'Duyệt +${task.coinReward} Xu',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showRejectDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          '❌ Từ chối nhiệm vụ',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhập lý do từ chối (tùy chọn):',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'VD: Con cần làm kỹ hơn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppTheme.bg,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Hủy',
              style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () {
              context.read<AppState>().rejectTask(task.id);
              Navigator.pop(dialogCtx);
              final reason = ctrl.text.trim();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    reason.isEmpty
                        ? '❌ Đã từ chối. Con sẽ cần làm lại.'
                        : '❌ Từ chối: $reason',
                  ),
                  backgroundColor: const Color(0xFFEF4444),
                ),
              );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: Text(
              'Từ chối',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showApprovalDialog(BuildContext outerCtx) {
    showDialog(
      context: outerCtx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 14),
            Text(
              'Tuyệt vời!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đã duyệt và cộng ${task.coinReward} Xu cho ${outerCtx.read<AppState>().childName}! 🎉',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppTheme.gradientGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: FilledButton(
                onPressed: () {
                  outerCtx.read<AppState>().approveTask(task.id);
                  Navigator.pop(dialogCtx);
                  Navigator.pop(outerCtx);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Xong ✓',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;

  const _StatusBanner({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
