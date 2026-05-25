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

class _ChildTaskListState extends State<ChildTaskList> with SingleTickerProviderStateMixin {
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
          backgroundColor: AppTheme.surfaceBright,
          body: Column(
            children: [
              _buildHeader(todo.length, approved.length),
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
        );
      },
    );
  }

  Widget _buildHeader(int todoCount, int doneCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhiệm vụ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$todoCount việc cần làm · $doneCount đã xong',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.outline,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chỉ Bố/Mẹ mới có thể thêm nhiệm vụ mới!')),
                  );
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.onPrimaryFixedVariant,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(Icons.add, color: AppTheme.onTertiaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabCtrl,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              labelColor: AppTheme.vibrantPrimary,
              unselectedLabelColor: AppTheme.outline,
              labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: [
                Tab(text: 'Cần làm ($todoCount)'),
                Tab(text: 'Đã xong ($doneCount)'),
              ],
            ),
          ),
        ],
      ),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppTheme.surfaceContainer, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🎉', style: TextStyle(fontSize: 60)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  showAction ? 'Không có việc gì cần làm!' : 'Chưa hoàn thành việc nào',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  showAction ? 'Bố/Mẹ chưa giao việc gì hôm nay' : 'Hãy hoàn thành nhiệm vụ để tích lũy Xu nhé!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.outline,
                  ),
                ),
                if (showAction) ...[
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.vibrantPrimary,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: const [
                          BoxShadow(
                            color: AppTheme.onPrimaryFixedVariant,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.explore, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Khám phá hoạt động khác',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
      itemCount: tasks.length,
      itemBuilder: (context, i) => _TaskCardItem(
        task: tasks[i],
        showAction: showAction,
      ).animate(delay: Duration(milliseconds: i * 50)).fadeIn().slideY(begin: 0.1),
    );
  }
}

class _TaskCardItem extends StatelessWidget {
  final TaskModel task;
  final bool showAction;

  const _TaskCardItem({required this.task, required this.showAction});

  @override
  Widget build(BuildContext context) {
    final statusColor = task.status == TaskStatus.pending 
        ? AppTheme.vibrantPrimary 
        : (task.status == TaskStatus.submitted ? AppTheme.vibrantSecondary : AppTheme.vibrantTertiary);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.surfaceContainerHigh, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(task.icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      task.category,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppTheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryFixed,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '+${task.coinReward} Xu',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSecondaryFixed,
                  ),
                ),
              ),
            ],
          ),
          if (showAction && task.status == TaskStatus.pending) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                context.read<AppState>().submitTask(task.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã báo cáo! Đợi Bố/Mẹ duyệt nhé 🎉')),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceBright,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.vibrantPrimary, width: 2),
                ),
                child: Center(
                  child: Text(
                    'Đã làm xong — Báo cáo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.vibrantPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (task.status == TaskStatus.submitted) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.vibrantSecondary),
                ),
                const SizedBox(width: 8),
                Text(
                  'Đang chờ Bố/Mẹ duyệt...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.vibrantSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
