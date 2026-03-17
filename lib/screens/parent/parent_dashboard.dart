import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../models/task_model.dart';
import 'parent_task_detail.dart';
import 'parent_create_task.dart';
import 'parent_memory_lane.dart';
import 'parent_settings.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.parentTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('👨‍👩‍👧 GrowWise - Mentor Hub'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ParentSettings()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => _showBondingReminder(context),
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildDashboard(context),
            _buildTaskList(),
            const ParentMemoryLane(),
            _buildParentingAcademy(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard),
              label: 'Tổng quan',
            ),
            NavigationDestination(
              icon: Icon(Icons.task_alt),
              label: 'Nhiệm vụ',
            ),
            NavigationDestination(
              icon: Icon(Icons.photo_library),
              label: 'Kỷ niệm',
            ),
            NavigationDestination(icon: Icon(Icons.school), label: 'Học'),
          ],
        ),
        floatingActionButton: _currentIndex == 1
            ? FloatingActionButton.extended(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ParentCreateTask()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Giao việc'),
              )
            : null,
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final pendingCount = appState.submittedTasks.length;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bonding Reminder Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.accentOrange.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Bonding Reminder',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _bondingMessage(appState),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Stats
              const Text(
                'Tổng quan tuần này',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(
                    title: 'Đã giao',
                    value: '${appState.tasks.length}',
                    icon: Icons.assignment,
                    color: AppTheme.parentBlue,
                  ),
                  _StatCard(
                    title: 'Chờ duyệt',
                    value: '$pendingCount',
                    icon: Icons.pending_actions,
                    color: AppTheme.accentOrange,
                  ),
                  _StatCard(
                    title: 'Xu đã thưởng',
                    value: '${appState.totalCoinsRewarded}',
                    icon: Icons.monetization_on,
                    color: AppTheme.coinGold,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Child Profile Summary
              Text(
                'Hồ sơ con: ${appState.childName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.lightGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              appState.childAvatarEmoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.childName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Level ${appState.level} • ${appState.totalCoins} Xu',
                              style: const TextStyle(
                                color: AppTheme.textMedium,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            const Text('🏆', style: TextStyle(fontSize: 24)),
                            Text(
                              '${appState.badges.length} huy hiệu',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Jar summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _JarSummary('🛒', 'Tiêu dùng', appState.spendJar),
                        _JarSummary('🏦', 'Tiết kiệm', appState.saveJar),
                        _JarSummary('💝', 'Sẻ chia', appState.shareJar),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Tasks with pending approval
              if (pendingCount > 0) ...[
                Row(
                  children: [
                    const Text(
                      'Chờ duyệt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...appState.submittedTasks.map(
                  (task) => _PendingTaskCard(task: task),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskList() {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final tasks = appState.tasks;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _statusColor(task.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      task.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                title: Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 14)),
                    Text(' ${task.coinReward} Xu'),
                    const SizedBox(width: 12),
                    _StatusChip(task.status),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ParentTaskDetail(task: task),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildParentingAcademy() {
    final lessons = [
      {
        'title': 'Cách nói chuyện về tiền với con',
        'duration': '3 phút',
        'icon': '💬',
        'content':
            'Hãy bắt đầu từ những câu hỏi đơn giản: "Con muốn mua gì?" hay "Mình có đủ tiền không?". Đừng nói "nhà mình nghèo" mà hãy nói "hôm nay mình không mua cái này". Tập cho con hiểu tiền là công cụ, không phải mục đích.',
      },
      {
        'title': 'Khi nào nên thưởng, khi nào nên dừng',
        'duration': '5 phút',
        'icon': '🎯',
        'content':
            'Thưởng Xu hiệu quả nhất khi nhiệm vụ có giá trị thực sự. Tránh thưởng quá nhiều đến mức con chỉ làm việc vì tiền. Hãy kết hợp lời khen cùng với Xu để xây dựng động lực nội tâm.',
      },
      {
        'title': 'Xây dựng thói quen tiết kiệm từ nhỏ',
        'duration': '4 phút',
        'icon': '🏦',
        'content':
            'Hũ tiết kiệm giúp con hình dung rõ quá trình tích lũy. Đặt mục tiêu nhỏ như "để dành 50 Xu mua đồ chơi" thay vì tiết kiệm chung chung. Khi con đạt mục tiêu nhỏ, chúng tự tin đặt mục tiêu lớn hơn.',
      },
      {
        'title': 'Giúp con hiểu giá trị lao động',
        'duration': '3 phút',
        'icon': '💪',
        'content':
            'Kết nối nhiệm vụ với kết quả thực tế: "Con rửa bát giúp bố mẹ có thêm thời gian nấu ăn ngon". Hỏi con: "Con cảm thấy thế nào khi hoàn thành việc này?" để khuyến khích ý thức đóng góp.',
      },
      {
        'title': 'Sai lầm phổ biến khi dạy con về tiền',
        'duration': '4 phút',
        'icon': '⚠️',
        'content':
            'Tránh dùng tiền để kiểm soát: "Nếu con ngoan, bố/mẹ sẽ cho tiền". Đừng trừ tiền như hình phạt. Hãy để con trải nghiệm cả thành công lẫn thất bại nhỏ trong quản lý tiền để học từ thực tế.',
      },
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final l = lessons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.parentBlueLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(l['icon']!, style: const TextStyle(fontSize: 24)),
              ),
            ),
            title: Text(
              l['title']!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                const Icon(Icons.timer, size: 14, color: AppTheme.textLight),
                const SizedBox(width: 4),
                Text(
                  l['duration']!,
                  style: const TextStyle(color: AppTheme.textLight),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.play_circle_filled,
              color: AppTheme.parentBlue,
              size: 36,
            ),
            onTap: () => _showLessonDetail(context, l),
          ),
        );
      },
    );
  }

  void _showBondingReminder(BuildContext context) {
    final controller = TextEditingController();
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🤖 ', style: TextStyle(fontSize: 28)),
            Text('Gửi lời khen'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Gửi lời khen đến ${appState.childName} ngay hôm nay! 💛',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'VD: Con đã làm tốt lắm! Bố/Mẹ rất tự hào về con!',
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
            child: const Text('Để sau'),
          ),
          FilledButton.icon(
            onPressed: () {
              final msg = controller.text.trim();
              if (msg.isEmpty) return;
              appState.addBondingMessage(msg);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '💛 Đã gửi lời khen đến ${appState.childName}!',
                  ),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            icon: const Icon(Icons.send),
            label: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  String _bondingMessage(AppState appState) {
    final approved = appState.tasks
        .where((t) => t.status == TaskStatus.approved && t.reviewedAt != null)
        .toList();
    if (approved.isEmpty) {
      return 'Hãy giao việc cho ${appState.childName} và duyệt nhiệm vụ để bắt đầu! 🌱';
    }
    final lastDate = approved
        .map((t) => t.reviewedAt!)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final days = DateTime.now().difference(lastDate).inDays;
    if (days == 0) {
      return 'Bạn đã duyệt nhiệm vụ hôm nay. Tuyệt vời! Hãy gửi thêm lời khen cho ${appState.childName} nhé! 🎉';
    }
    return 'Đã $days ngày bạn chưa gửi lời khen cho ${appState.childName}. Hãy gửi một lời khen nhé! 💛';
  }

  void _showLessonDetail(BuildContext context, Map<String, String> lesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lesson['icon']!, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lesson['title']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.timer, size: 16, color: AppTheme.textLight),
                const SizedBox(width: 4),
                Text(
                  lesson['duration']!,
                  style: const TextStyle(color: AppTheme.textLight),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              lesson['content']!,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đã đọc xong ✓'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return AppTheme.textLight;
      case TaskStatus.submitted:
        return AppTheme.accentOrange;
      case TaskStatus.approved:
        return AppTheme.primaryGreen;
      case TaskStatus.rejected:
        return Colors.red;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _JarSummary extends StatelessWidget {
  final String emoji;
  final String label;
  final int value;

  const _JarSummary(this.emoji, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          '$value Xu',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
        ),
      ],
    );
  }
}

class _PendingTaskCard extends StatelessWidget {
  final TaskModel task;

  const _PendingTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFFFFF8E1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Text(task.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '🪙 ${task.coinReward} Xu',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ParentTaskDetail(task: task),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
              child: const Text('Duyệt'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TaskStatus status;

  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    switch (status) {
      case TaskStatus.pending:
        label = 'Chờ làm';
        color = AppTheme.textLight;
      case TaskStatus.submitted:
        label = 'Chờ duyệt';
        color = AppTheme.accentOrange;
      case TaskStatus.approved:
        label = 'Đã duyệt';
        color = AppTheme.primaryGreen;
      case TaskStatus.rejected:
        label = 'Từ chối';
        color = Colors.red;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
