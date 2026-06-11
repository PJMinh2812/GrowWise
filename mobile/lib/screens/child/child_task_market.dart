import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../models/task_model.dart';

// ─── Market task data model ───────────────────────────────────────────────────

class _MarketTask {
  final String emoji;
  final String title;
  final String description;
  final String category;
  final int difficulty; // 1=easy 2=medium 3=hard
  final int coins;
  final bool isRequired;

  const _MarketTask({
    required this.emoji,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.coins,
    required this.isRequired,
  });
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class ChildTaskMarket extends StatefulWidget {
  const ChildTaskMarket({super.key});

  @override
  State<ChildTaskMarket> createState() => _ChildTaskMarketState();
}

class _ChildTaskMarketState extends State<ChildTaskMarket> {
  int _filter = 0; // 0=All 1=Easy 2=Medium 3=Hard 4=Required

  static const _allTasks = [
    _MarketTask(
      emoji: '🛏️',
      title: 'Dọn giường ngủ',
      description: 'Gấp chăn gối gọn gàng mỗi sáng sau khi thức dậy.',
      category: 'Việc nhà',
      difficulty: 1,
      coins: 10,
      isRequired: true,
    ),
    _MarketTask(
      emoji: '📚',
      title: 'Đọc 10 trang sách',
      description: 'Chọn cuốn sách yêu thích và đọc ít nhất 10 trang.',
      category: 'Học tập',
      difficulty: 2,
      coins: 20,
      isRequired: false,
    ),
    _MarketTask(
      emoji: '🧹',
      title: 'Quét nhà',
      description:
          'Giúp ba mẹ giữ sàn nhà sạch bong kin kít! Đừng quên quét các góc kẹt nhé.',
      category: 'Việc nhà',
      difficulty: 3,
      coins: 30,
      isRequired: false,
    ),
    _MarketTask(
      emoji: '🐶',
      title: 'Cho cún ăn',
      description: 'Nhớ đổ thức ăn cho cún và thay nước sạch nhé.',
      category: 'Chăm sóc',
      difficulty: 1,
      coins: 10,
      isRequired: false,
    ),
    _MarketTask(
      emoji: '🍽️',
      title: 'Rửa bát sau bữa tối',
      description: 'Rửa sạch bát đĩa và để đúng chỗ sau bữa ăn tối.',
      category: 'Việc nhà',
      difficulty: 2,
      coins: 15,
      isRequired: false,
    ),
    _MarketTask(
      emoji: '🌿',
      title: 'Tưới cây',
      description: 'Tưới đủ nước cho các chậu cây trong nhà.',
      category: 'Chăm sóc',
      difficulty: 1,
      coins: 8,
      isRequired: false,
    ),
    _MarketTask(
      emoji: '📝',
      title: 'Làm bài tập về nhà',
      description:
          'Hoàn thành hết bài tập cô giáo giao trước khi xem TV.',
      category: 'Học tập',
      difficulty: 2,
      coins: 25,
      isRequired: false,
    ),
    _MarketTask(
      emoji: '🧺',
      title: 'Gấp quần áo',
      description: 'Gấp quần áo sạch và cất vào tủ đúng chỗ.',
      category: 'Việc nhà',
      difficulty: 2,
      coins: 12,
      isRequired: false,
    ),
    _MarketTask(
      emoji: '🪥',
      title: 'Đánh răng 2 lần/ngày',
      description: 'Sáng và tối đều đánh răng đúng 2 phút nhé!',
      category: 'Sức khỏe',
      difficulty: 1,
      coins: 5,
      isRequired: true,
    ),
    _MarketTask(
      emoji: '🧽',
      title: 'Lau bàn học',
      description: 'Lau sạch bàn học và sắp xếp sách vở ngay ngắn.',
      category: 'Việc nhà',
      difficulty: 1,
      coins: 8,
      isRequired: false,
    ),
  ];

  List<_MarketTask> _filtered() {
    switch (_filter) {
      case 1:
        return _allTasks.where((t) => t.difficulty == 1).toList();
      case 2:
        return _allTasks.where((t) => t.difficulty == 2).toList();
      case 3:
        return _allTasks.where((t) => t.difficulty == 3).toList();
      case 4:
        return _allTasks.where((t) => t.isRequired).toList();
      default:
        return List.of(_allTasks);
    }
  }

  @override
  Widget build(BuildContext context) {
    final claimedTitles = context
        .watch<AppState>()
        .pendingTasks
        .map((t) => t.title)
        .toSet();
    final filtered = _filtered();
    final requiredTasks = _allTasks.where((t) => t.isRequired).toList();
    final optionalFiltered =
        filtered.where((t) => !t.isRequired).toList();
    final availableCount =
        _allTasks.where((t) => !claimedTitles.contains(t.title)).length;

    return Theme(
      data: AppTheme.childTheme(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F3),
        body: Column(
          children: [
            _buildHeader(context, availableCount),
            _buildFilterTabs(),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // Pinned required section (tab 0 or tab 4)
                  if (_filter == 0 || _filter == 4) ...[
                    _buildPinnedSection(context, requiredTasks, claimedTitles),
                    const SizedBox(height: 20),
                  ],
                  // Optional tasks
                  if (optionalFiltered.isNotEmpty) ...[
                    if (_filter == 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Việc tự chọn',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF211B10),
                          ),
                        ),
                      ),
                    ...optionalFiltered.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TaskCard(
                          task: task,
                          isClaimed: claimedTitles.contains(task.title),
                          onTap: () =>
                              _showClaimSheet(context, task, claimedTitles),
                        ),
                      ),
                    ),
                  ] else if (_filter != 0 && _filter != 4) ...[
                    const SizedBox(height: 60),
                    Center(
                      child: Column(
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            'Không có nhiệm vụ nào!',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF564334),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildHeader(BuildContext context, int availableCount) {
    return Container(
      color: const Color(0xFFFFF8F3),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: const Color(0xFF904D00),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chợ Nhiệm Vụ 🏪',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF904D00),
                      ),
                    ),
                    Text(
                      'Chọn việc con muốn làm hôm nay',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF564334),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFB29BFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notifications_active_rounded,
                        size: 14, color: Color(0xFF4600BB)),
                    const SizedBox(width: 4),
                    Text(
                      '$availableCount trống',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4600BB),
                      ),
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

  Widget _buildFilterTabs() {
    const labels = ['Tất cả', 'Dễ ⭐', 'Vừa ⭐⭐', 'Khó ⭐⭐⭐', '🔒 Bắt buộc'];
    return Container(
      color: const Color(0xFFFFF8F3),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: List.generate(labels.length, (i) {
                final active = _filter == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF904D00)
                            : const Color(0xFFF4E6D5),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF904D00)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        labels[i],
                        style: GoogleFonts.nunitoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: active
                              ? Colors.white
                              : const Color(0xFF564334),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Container(height: 1, color: const Color(0xFFDDC1AE)),
        ],
      ),
    );
  }

  Widget _buildPinnedSection(
    BuildContext context,
    List<_MarketTask> requiredTasks,
    Set<String> claimedTitles,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFF8C00).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: const Border(
          left: BorderSide(color: Color(0xFFFF8C00), width: 4),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_rounded,
                  size: 20, color: Color(0xFF904D00)),
              const SizedBox(width: 8),
              Text(
                'Việc bắt buộc hôm nay',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF904D00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...requiredTasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PinnedTaskCard(
                task: task,
                isClaimed: claimedTitles.contains(task.title),
                onTap: () =>
                    _showClaimSheet(context, task, claimedTitles),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClaimSheet(
    BuildContext context,
    _MarketTask task,
    Set<String> claimedTitles,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClaimSheet(
        task: task,
        isClaimed: claimedTitles.contains(task.title),
      ),
    );
  }
}

// ─── Pinned task card (inside amber section) ─────────────────────────────────

class _PinnedTaskCard extends StatelessWidget {
  final _MarketTask task;
  final bool isClaimed;
  final VoidCallback onTap;

  const _PinnedTaskCard({
    required this.task,
    required this.isClaimed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF904D00).withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFAECDA),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(task.emoji,
                    style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF211B10),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _DifficultyBadge(task.difficulty),
                      const SizedBox(width: 8),
                      Text(
                        '🪙 ${task.coins} xu',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF904D00),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isClaimed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF006E1C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Đang làm →',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF006E1C),
                  ),
                ),
              )
            else
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAECDA),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFB77D)),
                ),
                child: const Icon(Icons.add_rounded,
                    size: 20, color: Color(0xFF904D00)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Optional task card ───────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final _MarketTask task;
  final bool isClaimed;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.isClaimed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isClaimed
              ? Border.all(
                  color: const Color(0xFF006E1C).withValues(alpha: 0.4),
                  width: 2,
                )
              : Border.all(color: const Color(0xFFDDC1AE)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF904D00).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFAECDA),
                shape: BoxShape.circle,
              ),
              child: Center(
                child:
                    Text(task.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF211B10),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _DifficultyBadge(task.difficulty),
                      const SizedBox(width: 8),
                      Text(
                        '🪙 ${task.coins} xu',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF904D00),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isClaimed)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006E1C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF006E1C).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Đang làm →',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF006E1C),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAECDA),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFB77D)),
                ),
                child: const Icon(Icons.add_rounded,
                    size: 22, color: Color(0xFF904D00)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Difficulty badge ─────────────────────────────────────────────────────────

class _DifficultyBadge extends StatelessWidget {
  final int difficulty;
  const _DifficultyBadge(this.difficulty);

  @override
  Widget build(BuildContext context) {
    final label = difficulty == 1
        ? 'Dễ ⭐'
        : difficulty == 2
            ? 'Vừa ⭐⭐'
            : 'Khó ⭐⭐⭐';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEEE0CF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunitoSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF564334),
        ),
      ),
    );
  }
}

// ─── Claim bottom sheet ───────────────────────────────────────────────────────

class _ClaimSheet extends StatefulWidget {
  final _MarketTask task;
  final bool isClaimed;

  const _ClaimSheet({required this.task, required this.isClaimed});

  @override
  State<_ClaimSheet> createState() => _ClaimSheetState();
}

class _ClaimSheetState extends State<_ClaimSheet> {
  bool _claiming = false;

  Future<void> _claim() async {
    setState(() => _claiming = true);
    final app = context.read<AppState>();
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    await app.addTask(
      TaskModel(
        id: '',
        title: widget.task.title,
        description: widget.task.description,
        category: widget.task.category,
        icon: widget.task.emoji,
        coinReward: widget.task.coins,
        hasPenalty: true,
        penaltyPercent: 10,
      ),
    );

    if (!mounted) return;
    nav.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '✅ Đã nhận "${widget.task.title}"! Vào mục Nhiệm Vụ để làm nhé 🎉',
        ),
        backgroundColor: const Color(0xFF006E1C),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomPad),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 6,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFDDC1AE),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Emoji + close
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFAECDA),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(widget.task.emoji,
                      style: const TextStyle(fontSize: 42)),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4E6D5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: Color(0xFF564334)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Title + description
          Text(
            widget.task.title,
            style: GoogleFonts.nunitoSans(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF211B10),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.task.description,
            style: GoogleFonts.nunitoSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF564334),
            ),
          ),
          const SizedBox(height: 20),
          // Difficulty + Reward info cards
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: 'Độ khó',
                  value: widget.task.difficulty == 1
                      ? 'Dễ ⭐'
                      : widget.task.difficulty == 2
                          ? 'Vừa ⭐⭐'
                          : 'Khó ⭐⭐⭐',
                  bgColor: const Color(0xFFF4E6D5),
                  borderColor: const Color(0xFFDDC1AE),
                  valueColor: const Color(0xFF211B10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  label: 'Phần thưởng',
                  value: '🪙 ${widget.task.coins} xu',
                  bgColor: const Color(0xFFFFDCC3),
                  borderColor: const Color(0xFFFFB77D),
                  valueColor: const Color(0xFF904D00),
                  valueFontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // CTA or "already claimed" state
          if (widget.isClaimed) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF006E1C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: const Color(0xFF006E1C).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF006E1C)),
                  const SizedBox(width: 8),
                  Text(
                    'Đang thực hiện nhiệm vụ này!',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF006E1C),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _claiming ? null : _claim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C00),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFFFF8C00).withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ).copyWith(
                  side: WidgetStateProperty.all(
                    const BorderSide(color: Color(0xFFCC7000), width: 0),
                  ),
                ),
                child: _claiming
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3),
                      )
                    : Text(
                        'Nhận nhiệm vụ này! 🙌',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Xem lúc khác',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF564334),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color bgColor;
  final Color borderColor;
  final Color valueColor;
  final double valueFontSize;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.bgColor,
    required this.borderColor,
    required this.valueColor,
    this.valueFontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF564334),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.nunitoSans(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
