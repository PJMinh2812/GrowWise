import 'package:flutter/material.dart';
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
        appBar: AppBar(title: Text(task.title)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task header
              Center(
                child: Text(task.icon, style: const TextStyle(fontSize: 72)),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.coinGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🪙 ${task.coinReward} Xu',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.coinGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Mô tả nhiệm vụ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 24),

              // If task is submitted, show proof section
              if (task.status == TaskStatus.submitted) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.accentOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.camera_alt, color: AppTheme.accentOrange),
                          SizedBox(width: 8),
                          Text(
                            'Bằng chứng từ con',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Placeholder image
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              '📸 Ảnh con chụp khi hoàn thành',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tôm gửi lúc 15:30 hôm nay',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Praise message
                const _PraiseSection(),
                const SizedBox(height: 30),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRejectDialog(context),
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text(
                          'Từ chối',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          _showApprovalDialog(context);
                        },
                        icon: const Icon(Icons.check),
                        label: Text('Duyệt +${task.coinReward} Xu'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // If task is approved
              if (task.status == TaskStatus.approved)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Text('✅', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 8),
                      Text(
                        'Đã duyệt!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGreen,
                        ),
                      ),
                      Text(
                        'Xu đã được cộng vào tài khoản của con',
                        style: TextStyle(color: AppTheme.textMedium),
                      ),
                    ],
                  ),
                ),

              // If task is pending
              if (task.status == TaskStatus.pending)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Text('⏳', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 8),
                      Text(
                        'Chờ con hoàn thành',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      Text(
                        'Nhiệm vụ đã được giao, chờ con nộp bằng chứng',
                        style: TextStyle(color: AppTheme.textLight),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('❌ Từ chối nhiệm vụ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nhập lý do từ chối (tùy chọn):',
              style: TextStyle(fontSize: 14, color: AppTheme.textMedium),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'VD: Con cần làm kỹ hơn, chụp ảnh rõ hơn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              context.read<AppState>().rejectTask(task.id);
              Navigator.pop(dialogCtx);
              final reason = controller.text.trim();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    reason.isEmpty
                        ? '❌ Đã từ chối. Con sẽ cần làm lại.'
                        : '❌ Từ chối: $reason',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }

  void _showApprovalDialog(BuildContext outerContext) {
    showDialog(
      context: outerContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            const Text(
              'Tuyệt vời!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Đã duyệt nhiệm vụ và cộng ${task.coinReward} Xu cho ${outerContext.read<AppState>().childName}! 🎉',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMedium),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                outerContext.read<AppState>().approveTask(task.id);
                Navigator.pop(dialogContext);
                Navigator.pop(outerContext);
              },
              child: const Text('Xong'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PraiseSection extends StatefulWidget {
  const _PraiseSection();

  @override
  State<_PraiseSection> createState() => _PraiseSectionState();
}

class _PraiseSectionState extends State<_PraiseSection> {
  final _controller = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childName = context.read<AppState>().childName;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.parentBlueLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💬 Gửi lời khen cho con',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lời khen sẽ xuất hiện trên màn hình của con',
            style: TextStyle(fontSize: 13, color: AppTheme.textMedium),
          ),
          const SizedBox(height: 12),
          if (_sent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.darkGreen),
                  SizedBox(width: 8),
                  Text(
                    '✅ Đã gửi lời khen!',
                    style: TextStyle(
                      color: AppTheme.darkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'VD: Con đã làm rất tốt! Bố/Mẹ rất tự hào về con!',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final msg = _controller.text.trim();
                  if (msg.isEmpty) return;
                  context.read<AppState>().addBondingMessage(msg);
                  setState(() => _sent = true);
                },
                icon: const Icon(Icons.send),
                label: Text('Gửi lời khen cho $childName'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.parentBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
