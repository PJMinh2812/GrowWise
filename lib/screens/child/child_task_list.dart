import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../models/task_model.dart';

class ChildTaskList extends StatelessWidget {
  const ChildTaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final pendingTasks = appState.pendingTasks;
        final submittedTasks = appState.submittedTasks;
        final approvedTasks = appState.approvedTasks;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Treasure map header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text('🗺️', style: TextStyle(fontSize: 40)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bản đồ kho báu',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Hoàn thành nhiệm vụ để nhận Xu! Còn ${pendingTasks.length} nhiệm vụ chờ con!',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pending tasks
              if (pendingTasks.isNotEmpty) ...[
                _SectionTitle(
                  '⚡ Cần làm (${pendingTasks.length})',
                  AppTheme.accentOrange,
                ),
                const SizedBox(height: 8),
                ...pendingTasks.map(
                  (task) => _ChildTaskCard(
                    task: task,
                    actionLabel: 'Bắt đầu làm!',
                    actionColor: AppTheme.primaryGreen,
                    onAction: () => _showSubmitDialog(context, task),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Submitted - waiting approval
              if (submittedTasks.isNotEmpty) ...[
                _SectionTitle(
                  '⏳ Chờ duyệt (${submittedTasks.length})',
                  AppTheme.accentOrange,
                ),
                const SizedBox(height: 8),
                ...submittedTasks.map(
                  (task) => _ChildTaskCard(
                    task: task,
                    actionLabel: 'Đang chờ bố mẹ duyệt...',
                    actionColor: AppTheme.textLight,
                    onAction: null,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Completed tasks
              if (approvedTasks.isNotEmpty) ...[
                _SectionTitle(
                  '✅ Hoàn thành (${approvedTasks.length})',
                  AppTheme.primaryGreen,
                ),
                const SizedBox(height: 8),
                ...approvedTasks.map(
                  (task) => _ChildTaskCard(
                    task: task,
                    actionLabel: 'Đã nhận ${task.coinReward} Xu! 🎉',
                    actionColor: AppTheme.primaryGreen,
                    onAction: null,
                    isCompleted: true,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showSubmitDialog(BuildContext context, TaskModel task) {
    final outerContext = context;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(task.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Expanded(child: Text(task.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 36,
                    color: AppTheme.primaryGreen,
                  ),
                  SizedBox(height: 8),
                  Text('📸 Chụp ảnh khi hoàn thành!'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '🪙 Phần thưởng: ${task.coinReward} Xu',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.coinGold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Để sau'),
          ),
          FilledButton.icon(
            onPressed: () {
              outerContext.read<AppState>().submitTask(task.id);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(outerContext).showSnackBar(
                SnackBar(
                  content: Text(
                    '📤 Đã nộp "${task.title}"! Chờ bố mẹ duyệt nhé!',
                  ),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            icon: const Icon(Icons.send),
            label: const Text('Nộp bài'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;

  const _SectionTitle(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
    );
  }
}

class _ChildTaskCard extends StatelessWidget {
  final TaskModel task;
  final String actionLabel;
  final Color actionColor;
  final VoidCallback? onAction;
  final bool isCompleted;

  const _ChildTaskCard({
    required this.task,
    required this.actionLabel,
    required this.actionColor,
    this.onAction,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.lightGreen
                    : AppTheme.accentYellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(task.icon, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '🪙 ${task.coinReward} Xu',
                        style: const TextStyle(fontSize: 13),
                      ),
                      if (isCompleted) ...[
                        const SizedBox(width: 8),
                        const Text('✅', style: TextStyle(fontSize: 14)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (onAction != null)
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: actionColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: Text(actionLabel, style: const TextStyle(fontSize: 12)),
              )
            else
              Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: actionColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
