import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../models/task_model.dart';

class ChildTaskList extends StatefulWidget {
  const ChildTaskList({super.key});

  @override
  State<ChildTaskList> createState() => _ChildTaskListState();
}

class _ChildTaskListState extends State<ChildTaskList>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, child) {
        final pending = app.pendingTasks;
        final submitted = app.submittedTasks;
        final approved = app.approvedTasks;
        final todo = [...pending, ...submitted];

        return Scaffold(
          backgroundColor: AppTheme.bg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nhiệm vụ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '${todo.length} việc cần làm · ${approved.length} đã xong',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppTheme.textHint,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TabBar(
                        controller: _tabCtrl,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        labelColor: AppTheme.green,
                        unselectedLabelColor: AppTheme.textHint,
                        indicatorColor: AppTheme.green,
                        indicatorWeight: 2,
                        tabs: [
                          Tab(text: 'Cần làm (${todo.length})'),
                          Tab(text: 'Đã xong (${approved.length})'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _TaskSection(tasks: todo, showAction: true),
                      _TaskSection(tasks: approved, showAction: false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TaskSection extends StatelessWidget {
  final List<TaskModel> tasks;
  final bool showAction;
  const _TaskSection({required this.tasks, required this.showAction});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              showAction ? '🎉' : '📭',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              showAction ? 'Không có việc gì cần làm!' : 'Chưa hoàn thành việc nào',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
            ),
            if (showAction) ...[
              const SizedBox(height: 4),
              Text(
                'Bố/Mẹ chưa giao việc gì hôm nay',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppTheme.textHint,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      itemCount: tasks.length,
      itemBuilder: (context, i) => _TaskCard(
        task: tasks[i],
        showAction: showAction,
        index: i,
      )
          .animate(delay: Duration(milliseconds: i * 25))
          .fadeIn(duration: 160.ms)
          .slideY(begin: 0.05, end: 0),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final bool showAction;
  final int index;
  const _TaskCard({required this.task, required this.showAction, required this.index});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusInfo(task.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: statusInfo.$2, width: 3),
          top: BorderSide(color: AppTheme.border),
          right: BorderSide(color: AppTheme.border),
          bottom: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusInfo.$2.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(task.icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    task.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textHint,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Category chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.bg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(
                          task.category,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Coin reward
                      Text(
                        '${task.coinReward} xu 🪙',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      const Spacer(),
                      // Status
                      Text(
                        statusInfo.$1,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusInfo.$2,
                        ),
                      ),
                    ],
                  ),

                  // Action button for pending tasks
                  if (showAction && task.status == TaskStatus.pending) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _submitTask(context, task),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.green,
                          side: const BorderSide(color: AppTheme.green, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          'Đã làm xong — Báo cáo',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Waiting badge
                  if (task.status == TaskStatus.submitted) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(
                          width: 12, height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Đang chờ Bố/Mẹ duyệt...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFFF59E0B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, Color) _statusInfo(TaskStatus s) => switch (s) {
    TaskStatus.pending => ('Chờ làm', AppTheme.textHint),
    TaskStatus.submitted => ('Chờ duyệt', const Color(0xFFF59E0B)),
    TaskStatus.approved => ('Hoàn thành ✓', AppTheme.green),
    TaskStatus.rejected => ('Cần làm lại', AppTheme.coral),
  };

  void _submitTask(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SubmitSheet(task: task),
    );
  }
}

class _SubmitSheet extends StatelessWidget {
  final TaskModel task;
  const _SubmitSheet({required this.task});

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
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Xác nhận hoàn thành',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${task.icon} ${task.title}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bạn sẽ nhận được ${task.coinReward} xu sau khi Bố/Mẹ duyệt.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppTheme.textHint,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                context.read<AppState>().submitTask(task.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã báo cáo! Đợi Bố/Mẹ duyệt nhé 🎉'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.green,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Xác nhận đã làm xong!',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Huỷ',
                style: GoogleFonts.plusJakartaSans(color: AppTheme.textHint),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
