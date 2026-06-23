import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final app = context.watch<AppState>();
    final s = app.strings;
    // Live task: prefer version from childViewTasks (has submissionId), else raw template
    final liveTask = app.childViewTasks.firstWhere(
      (t) => t.id == task.id,
      orElse: () => task,
    );
    return Theme(
      data: AppTheme.parentTheme(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
          title: Text(
            liveTask.title,
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
              _TaskHero(task: liveTask),
              const SizedBox(height: 24),

              if (liveTask.autoApproveAfter != null) ...[
                _AutoApproveProgress(task: liveTask),
                const SizedBox(height: 20),
              ],

              if (liveTask.description.isNotEmpty) ...[
                Text(
                  s.taskDescSection,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
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
                    liveTask.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15, height: 1.6, color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              if (liveTask.status == TaskStatus.submitted) ...[
                _ProofSection(taskId: liveTask.id, submittedAt: liveTask.submittedAt, proofImageUrl: liveTask.proofImageUrl),
                const SizedBox(height: 20),
                _PraiseSection(),
                const SizedBox(height: 28),
                _ActionButtons(task: liveTask),
              ],

              if (liveTask.status == TaskStatus.approved) ...[
                _StatusBanner(
                  emoji: liveTask.autoApproved ? '⚡' : '✅',
                  title: liveTask.autoApproved ? 'Đã tự duyệt' : s.approvedStatus,
                  subtitle: liveTask.autoApproved ? 'Kiểm tra ảnh — có thể huỷ trong 24h' : s.coinsAdded,
                  color: liveTask.autoApproved ? const Color(0xFFFF8F00) : AppTheme.green,
                  bgColor: liveTask.autoApproved ? const Color(0xFFFFF8E1) : AppTheme.greenLight,
                ),
                if (liveTask.autoApproved && liveTask.proofImageUrl != null) ...[
                  const SizedBox(height: 16),
                  _ProofSection(taskId: liveTask.id, submittedAt: liveTask.submittedAt, proofImageUrl: liveTask.proofImageUrl),
                ],
                if (liveTask.autoApproved && liveTask.reviewedAt != null &&
                    DateTime.now().difference(liveTask.reviewedAt!).inHours < 24) ...[
                  const SizedBox(height: 16),
                  _RetroactiveRejectButton(task: liveTask),
                ],
                const SizedBox(height: 12),
              ],

              if (liveTask.status == TaskStatus.rejected)
                _StatusBanner(
                  emoji: '❌',
                  title: s.rejectedStatus,
                  subtitle: s.redoMsg,
                  color: const Color(0xFFEF4444),
                  bgColor: const Color(0xFFFEF2F2),
                ),

              // Not yet assigned → show assign button
              if (liveTask.submissionId == null) ...[
                _AssignButton(taskId: liveTask.id),
              ] else if (liveTask.status == TaskStatus.pending) ...[
                _StatusBanner(
                  emoji: '⏳',
                  title: s.pendingStatus,
                  subtitle: s.pendingMsg,
                  color: AppTheme.textSecondary,
                  bgColor: AppTheme.bg,
                ),
              ],

              const SizedBox(height: 16),
              _DeactivateButton(task: liveTask),
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
    final s = context.watch<AppState>().strings;
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
            style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
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
              '🪙 ${task.coinReward} ${s.coins}',
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProofSection extends StatelessWidget {
  final String taskId;
  final DateTime? submittedAt;
  final String? proofImageUrl;
  const _ProofSection({required this.taskId, this.submittedAt, this.proofImageUrl});

  Widget _noPhotoPlaceholder(String msg) => Container(
    height: 180, width: double.infinity,
    decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.image_not_supported_outlined, size: 44, color: AppTheme.textHint),
      const SizedBox(height: 8),
      Text(msg, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textHint)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().strings;
    final proofBytes = context.watch<AppState>().getTaskProofBytes(taskId);

    Widget buildImage() {
      if (proofBytes != null) {
        return Image.memory(proofBytes, height: 220, width: double.infinity,
          fit: BoxFit.cover, errorBuilder: (_, _, _) => _noPhotoPlaceholder(s.noProof));
      }
      if (proofImageUrl != null && proofImageUrl!.isNotEmpty) {
        if (proofImageUrl!.startsWith('data:')) {
          try {
            final bytes = base64Decode(proofImageUrl!.split(',').last);
            return Image.memory(bytes, height: 220, width: double.infinity,
              fit: BoxFit.cover, errorBuilder: (_, _, _) => _noPhotoPlaceholder(s.noProof));
          } catch (_) {}
        }
        return CachedNetworkImage(
          imageUrl: proofImageUrl!,
          height: 220, width: double.infinity, fit: BoxFit.cover,
          placeholder: (_, _) => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
          errorWidget: (_, _, _) => _noPhotoPlaceholder(s.noProof),
        );
      }
      return _noPhotoPlaceholder(s.noProof);
    }

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
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.camera_alt_outlined, color: AppTheme.amber, size: 20),
            ),
            const SizedBox(width: 10),
            Text(s.proofSection, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textPrimary)),
          ]),
          const SizedBox(height: 14),
          ClipRRect(borderRadius: BorderRadius.circular(12), child: buildImage()),
          const SizedBox(height: 10),
          Text(
            submittedAt != null
                ? s.submittedAt(
                    '${submittedAt!.hour.toString().padLeft(2, '0')}:${submittedAt!.minute.toString().padLeft(2, '0')}',
                    '${submittedAt!.day}/${submittedAt!.month}',
                  )
                : s.approvedStatus,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textHint),
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
    final app = context.read<AppState>();
    final s = context.watch<AppState>().strings;
    final childName = app.childName;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppTheme.indigoLight, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.praiseTitle, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(s.praiseSub, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 14),
          if (_sent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: AppTheme.greenLight, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded, color: AppTheme.green),
                const SizedBox(width: 8),
                Text(s.praiseSent, style: GoogleFonts.plusJakartaSans(color: AppTheme.green, fontWeight: FontWeight.w700)),
              ]),
            )
          else ...[
            TextField(
              controller: _ctrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: s.praiseHint,
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.send_rounded, size: 16),
                label: Text(s.sendPraiseTo(childName), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
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
    final s = context.watch<AppState>().strings;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showRejectDialog(context, s),
            icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444)),
            label: Text(s.reject, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: const Color(0xFFEF4444))),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFEF4444)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
              onPressed: () => _showQualityRatingSheet(context, s),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.star_rounded, color: Colors.white),
              label: Text(s.reviewAndApprove, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  void _showRejectDialog(BuildContext context, dynamic s) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(s.rejectTaskTitle, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.rejectReason, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: s.rejectReasonHint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: AppTheme.bg,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(s.cancel, style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              final reason = ctrl.text.trim();
              context.read<AppState>().rejectTask(task.id, reason: reason.isNotEmpty ? reason : null);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(reason.isEmpty ? s.rejectedNoReason() : s.rejectedWithReason(reason)),
                backgroundColor: const Color(0xFFEF4444),
              ));
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: Text(s.reject, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showQualityRatingSheet(BuildContext outerCtx, dynamic s) {
    showModalBottomSheet(
      context: outerCtx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QualityRatingSheet(task: task, outerCtx: outerCtx, s: s),
    );
  }

}

class _QualityRatingSheet extends StatefulWidget {
  final TaskModel task;
  final BuildContext outerCtx;
  final dynamic s;
  const _QualityRatingSheet({required this.task, required this.outerCtx, required this.s});

  @override
  State<_QualityRatingSheet> createState() => _QualityRatingSheetState();
}

class _QualityRatingSheetState extends State<_QualityRatingSheet> {
  int _rating = 2;
  bool _loading = false;

  static const _ratingData = [
    (emoji: '😐', label: 'Làm cho xong', pct: '80%', multiplier: 0.8, color: Color(0xFFF59E0B), bg: Color(0xFFFFFBEB)),
    (emoji: '🙂', label: 'Hoàn thành tốt', pct: '100%', multiplier: 1.0, color: Color(0xFF3DBE6E), bg: Color(0xFFEBF9F1)),
    (emoji: '🎉', label: 'Xuất sắc!', pct: '120%', multiplier: 1.2, color: Color(0xFF6B38D4), bg: Color(0xFFEDE9FF)),
  ];

  static const _praises = [
    'Con làm xong rồi nhưng có thể làm tốt hơn, lần sau cố lên nhé! 💪',
    'Cảm ơn con, đã hoàn thành nhiệm vụ đúng hạn! 👍',
    'Bố mẹ rất tự hào về con! Con thực sự xuất sắc! 🎉',
  ];

  int get _earnedCoins => (widget.task.coinReward * _ratingData[_rating - 1].multiplier).round();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().strings;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),
          Text(s.qualityRating,
            style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(s.qualityRatingSub,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          Row(
            children: List.generate(3, (i) {
              final d = _ratingData[i];
              final selected = _rating == i + 1;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    decoration: BoxDecoration(
                      color: selected ? d.bg : AppTheme.bg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? d.color : AppTheme.border, width: selected ? 2 : 1),
                    ),
                    child: Column(
                      children: [
                        Text(d.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(d.label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textPrimary), textAlign: TextAlign.center),
                        const SizedBox(height: 4),
                        Text(d.pct, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: d.color)),
                        Text('xu', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textHint)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(12)),
            child: Text(
              _praises[_rating - 1],
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary, fontStyle: FontStyle.italic, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppTheme.gradientGreen, borderRadius: BorderRadius.circular(14)),
              child: FilledButton(
                onPressed: _loading ? null : _onConfirm,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(s.approveWithCoins(_earnedCoins),
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() => _loading = true);
    final outerCtx = widget.outerCtx;
    final s = widget.s;
    await outerCtx.read<AppState>().approveTask(widget.task.id, rating: _rating);
    if (!mounted) return;
    Navigator.pop(context); // close sheet
    if (!outerCtx.mounted) return;
    final badge = outerCtx.read<AppState>().pendingStreakBadge;
    if (badge != null) {
      outerCtx.read<AppState>().consumeStreakBadge();
      await _showStreakDialog(outerCtx, badge, s);
    }
    if (outerCtx.mounted) Navigator.pop(outerCtx);
  }
}

Future<void> _showStreakDialog(BuildContext ctx, String badge, dynamic s) async {
  await showDialog(
    context: ctx,
    builder: (dialogCtx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(badge.split(' ').first, style: const TextStyle(fontSize: 72))
              .animate().scale(begin: const Offset(0.1, 0.1), duration: 700.ms, curve: Curves.elasticOut).fadeIn(duration: 300.ms),
          const SizedBox(height: 12),
          Text(badge.split(' ').sublist(1).join(' '),
            style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary))
              .animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 8),
          Text(s.streakBadgeMsg, textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textSecondary))
              .animate(delay: 400.ms).fadeIn(),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(dialogCtx),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.vibrantPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(s.excellent, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ],
    ),
  );
}

class _RetroactiveRejectButton extends StatefulWidget {
  final TaskModel task;
  const _RetroactiveRejectButton({required this.task});

  @override
  State<_RetroactiveRejectButton> createState() => _RetroactiveRejectButtonState();
}

class _RetroactiveRejectButtonState extends State<_RetroactiveRejectButton> {
  bool _loading = false;

  void _confirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.read<AppState>().strings.cancelAutoTitle,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text(
          'Xu đã trao sẽ bị thu hồi và con phải nộp lại bằng chứng đúng. Tiến độ auto-approve cũng giảm 1.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.read<AppState>().strings.nah, style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _loading = true);
              final appState = context.read<AppState>();
              final cancelledMsg = appState.strings.cancelledAutoMsg;
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              await appState.retroactiveRejectTask(widget.task.id,
                  submissionId: widget.task.submissionId);
              if (!mounted) return;
              setState(() => _loading = false);
              nav.pop();
              messenger.showSnackBar(SnackBar(
                content: Text(cancelledMsg),
                backgroundColor: const Color(0xFFEF4444),
              ));
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: Text(context.read<AppState>().strings.cancelAutoBtn, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : () => _confirm(context),
        icon: _loading
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.undo_rounded, size: 18),
        label: Text(
          _loading ? '…' : context.watch<AppState>().strings.cancelAutoBtn,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _AutoApproveProgress extends StatelessWidget {
  final TaskModel task;
  const _AutoApproveProgress({required this.task});

  @override
  Widget build(BuildContext context) {
    final target = task.autoApproveAfter!;
    final count = task.approvalCount;
    final reached = count >= target;
    final progress = (count / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: reached ? AppTheme.greenLight : AppTheme.primaryFixed,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: reached ? AppTheme.green : AppTheme.primaryFixedDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(reached ? '✅' : '⚡', style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              reached ? 'Task này đã bật Auto-approve!' : 'Tiến độ Auto-approve',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700,
                color: reached ? AppTheme.green : AppTheme.vibrantPrimary),
            ),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.6),
              valueColor: AlwaysStoppedAnimation<Color>(reached ? AppTheme.green : AppTheme.vibrantPrimary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            reached ? 'Các lần nộp tiếp theo sẽ tự được duyệt' : 'Đã duyệt $count/$target lần — còn ${target - count} lần nữa',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AssignButton extends StatefulWidget {
  final String taskId;
  const _AssignButton({required this.taskId});

  @override
  State<_AssignButton> createState() => _AssignButtonState();
}

class _AssignButtonState extends State<_AssignButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _loading ? null : _assign,
        icon: _loading
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send_rounded, size: 18),
        label: Text(
          'Giao cho con',
          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.primaryContainer,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Future<void> _assign() async {
    setState(() => _loading = true);
    await context.read<AppState>().assignTask(widget.taskId);
    if (mounted) setState(() => _loading = false);
  }
}

class _DeactivateButton extends StatelessWidget {
  final TaskModel task;
  const _DeactivateButton({required this.task});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () => _confirmDeactivate(context),
          icon: const Icon(Icons.pause_circle_outline, size: 18, color: AppTheme.outline),
          label: Text(context.watch<AppState>().strings.pauseTaskLabel,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.outline)),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () => _confirmDelete(context),
          icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
          label: Text(context.watch<AppState>().strings.deleteTaskLabel,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
        ),
      ],
    );
  }

  void _confirmDeactivate(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.read<AppState>().strings.pauseTaskTitle,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text(
          'Nhiệm vụ sẽ bị ẩn khỏi danh sách của con. Lịch sử hoàn thành vẫn được giữ lại.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.read<AppState>().strings.cancel, style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              context.read<AppState>().toggleTemplate(task.id);
              Navigator.pop(ctx);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.outline),
            child: Text(context.read<AppState>().strings.pauseTaskLabel, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.read<AppState>().strings.deleteTaskTitle,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text(
          'Toàn bộ lịch sử hoàn thành sẽ bị xóa vĩnh viễn. Không thể khôi phục.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.read<AppState>().strings.cancel, style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AppState>().deleteTemplate(task.id);
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: Text(context.read<AppState>().strings.deleteTaskLabel, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String emoji, title, subtitle;
  final Color color, bgColor;

  const _StatusBanner({required this.emoji, required this.title, required this.subtitle, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.25))),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 10),
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textSecondary)),
      ]),
    );
  }
}
