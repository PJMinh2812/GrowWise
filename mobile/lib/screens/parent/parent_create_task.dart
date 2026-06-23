import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/gemini_service.dart';
import '../../widgets/paywall_dialog.dart';
import '../../theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../utils/validators.dart';
import 'parent_task_detail.dart';
import '../../utils/age_group.dart';

class ParentCreateTask extends StatefulWidget {
  const ParentCreateTask({super.key});

  @override
  State<ParentCreateTask> createState() => _ParentCreateTaskState();
}

class _ParentCreateTaskState extends State<ParentCreateTask> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isSubmitting = false;
  int _coins = 15;
  String _category = 'Việc nhà';
  bool _loadingAi = false;
  List<Map<String, dynamic>>? _aiSuggestions;
  bool _deadlineEnabled = false;
  DateTime? _dueDate;
  bool _hasPenalty = false;
  bool _autoApproveEnabled = false;

  static const _allQuickIdeas = [
    // Việc nhà
    {'title': 'Rửa bát', 'icon': Icons.local_laundry_service, 'coins': 15, 'cat': 'Việc nhà', 'color': AppTheme.primaryFixed, 'onColor': AppTheme.onPrimaryFixed, 'borderColor': AppTheme.primaryFixedDim, 'ages': ['young', 'middle', 'older']},
    {'title': 'Quét nhà', 'icon': Icons.cleaning_services, 'coins': 10, 'cat': 'Việc nhà', 'color': AppTheme.secondaryFixed, 'onColor': AppTheme.onSecondaryFixed, 'borderColor': AppTheme.secondaryFixedDim, 'ages': ['young', 'middle', 'older']},
    {'title': 'Tưới cây', 'icon': Icons.yard, 'coins': 10, 'cat': 'Việc nhà', 'color': AppTheme.surfaceContainerHigh, 'onColor': AppTheme.vibrantPrimary, 'borderColor': AppTheme.outlineVariant, 'ages': ['young', 'middle', 'older']},
    {'title': 'Gấp quần áo', 'icon': Icons.checkroom, 'coins': 15, 'cat': 'Việc nhà', 'color': AppTheme.primaryFixed, 'onColor': AppTheme.onPrimaryFixed, 'borderColor': AppTheme.primaryFixedDim, 'ages': ['young', 'middle', 'older']},
    {'title': 'Xếp đồ chơi', 'icon': Icons.toys, 'coins': 8, 'cat': 'Việc nhà', 'color': AppTheme.secondaryFixed, 'onColor': AppTheme.onSecondaryFixed, 'borderColor': AppTheme.secondaryFixedDim, 'ages': ['young', 'middle']},
    {'title': 'Nấu ăn phụ bố mẹ', 'icon': Icons.restaurant, 'coins': 30, 'cat': 'Việc nhà', 'color': AppTheme.primaryFixed, 'onColor': AppTheme.onPrimaryFixed, 'borderColor': AppTheme.primaryFixedDim, 'ages': ['middle', 'older']},
    // Học tập
    {'title': 'Đọc sách', 'icon': Icons.menu_book, 'coins': 20, 'cat': 'Học tập', 'color': AppTheme.tertiaryFixed, 'onColor': AppTheme.onTertiaryFixed, 'borderColor': AppTheme.tertiaryFixedDim, 'ages': ['young', 'middle', 'older']},
    {'title': 'Ôn bài', 'icon': Icons.school, 'coins': 20, 'cat': 'Học tập', 'color': AppTheme.tertiaryFixed, 'onColor': AppTheme.onTertiaryFixed, 'borderColor': AppTheme.tertiaryFixedDim, 'ages': ['young', 'middle', 'older']},
    {'title': 'Học bảng cửu chương', 'icon': Icons.calculate, 'coins': 15, 'cat': 'Học tập', 'color': AppTheme.tertiaryFixed, 'onColor': AppTheme.onTertiaryFixed, 'borderColor': AppTheme.tertiaryFixedDim, 'ages': ['young']},
    {'title': 'Lập kế hoạch học tập', 'icon': Icons.edit_calendar, 'coins': 35, 'cat': 'Học tập', 'color': AppTheme.tertiaryFixed, 'onColor': AppTheme.onTertiaryFixed, 'borderColor': AppTheme.tertiaryFixedDim, 'ages': ['older']},
    // Sức khỏe
    {'title': 'Tập thể dục', 'icon': Icons.fitness_center, 'coins': 15, 'cat': 'Sức khỏe', 'color': AppTheme.errorContainer, 'onColor': AppTheme.onErrorContainer, 'borderColor': Color(0xFFFFB4AB), 'ages': ['young', 'middle', 'older']},
    {'title': 'Đánh răng 2 lần/ngày', 'icon': Icons.health_and_safety, 'coins': 8, 'cat': 'Sức khỏe', 'color': AppTheme.errorContainer, 'onColor': AppTheme.onErrorContainer, 'borderColor': Color(0xFFFFB4AB), 'ages': ['young']},
    {'title': 'Tự nấu bữa sáng lành mạnh', 'icon': Icons.breakfast_dining, 'coins': 35, 'cat': 'Sức khỏe', 'color': AppTheme.errorContainer, 'onColor': AppTheme.onErrorContainer, 'borderColor': Color(0xFFFFB4AB), 'ages': ['older']},
    // Sáng tạo
    {'title': 'Vẽ tranh', 'icon': Icons.palette, 'coins': 15, 'cat': 'Sáng tạo', 'color': AppTheme.secondaryFixed, 'onColor': AppTheme.onSecondaryFixed, 'borderColor': AppTheme.secondaryFixedDim, 'ages': ['young', 'middle', 'older']},
    {'title': 'Làm thiệp tặng ông bà', 'icon': Icons.card_giftcard, 'coins': 20, 'cat': 'Sáng tạo', 'color': AppTheme.secondaryFixed, 'onColor': AppTheme.onSecondaryFixed, 'borderColor': AppTheme.secondaryFixedDim, 'ages': ['young', 'middle', 'older']},
    {'title': 'Viết nhật ký', 'icon': Icons.book, 'coins': 20, 'cat': 'Sáng tạo', 'color': AppTheme.secondaryFixed, 'onColor': AppTheme.onSecondaryFixed, 'borderColor': AppTheme.secondaryFixedDim, 'ages': ['middle', 'older']},
  ];

  List<Map<String, Object>> get _filteredIdeas {
    final group = context.read<AppState>().childAge.ageGroup.name;
    return _allQuickIdeas
        .where((idea) => (idea['ages'] as List).contains(group))
        .toList();
  }

  static final _categories = [
    {'id': 'Việc nhà', 'icon': Icons.home, 'color': AppTheme.vibrantPrimary, 'bgColor': AppTheme.primaryFixed, 'onColor': AppTheme.onPrimaryFixedVariant},
    {'id': 'Học tập', 'icon': Icons.school, 'color': AppTheme.vibrantTertiary, 'bgColor': AppTheme.tertiaryFixed, 'onColor': AppTheme.onTertiaryFixedVariant},
    {'id': 'Sức khỏe', 'icon': Icons.favorite, 'color': Color(0xFF006B5F), 'bgColor': Color(0xFF78F8E4), 'onColor': Color(0xFF006B5F)},
    {'id': 'Sáng tạo', 'icon': Icons.palette, 'color': AppTheme.vibrantSecondary, 'bgColor': AppTheme.secondaryFixed, 'onColor': AppTheme.onSecondaryFixedVariant},
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAiSuggestions() async {
    setState(() { _loadingAi = true; _aiSuggestions = null; });
    final suggestions = await GeminiService.suggestTasks(
      childAge: context.read<AppState>().childAge,
      category: _category,
    );
    if (mounted) setState(() { _aiSuggestions = suggestions; _loadingAi = false; });
  }

  Widget _buildAiSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '✨ Gợi ý từ AI',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _loadingAi ? null : _loadAiSuggestions,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryFixed,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: AppTheme.primaryFixedDim, width: 2),
                ),
                child: _loadingAi
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.vibrantPrimary,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, size: 14, color: AppTheme.vibrantPrimary),
                          const SizedBox(width: 4),
                          Text(
                            _aiSuggestions == null ? 'Gợi ý ngay' : 'Gợi ý lại',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: AppTheme.vibrantPrimary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
        if (_aiSuggestions != null) ...[
          const SizedBox(height: 12),
          ..._aiSuggestions!.map((s) {
            final title = s['title'] as String? ?? '';
            final desc = s['description'] as String? ?? '';
            final icon = s['icon'] as String? ?? '📋';
            final coins = s['coins'] as int? ?? 15;
            return GestureDetector(
              onTap: () {
                _titleCtrl.text = title;
                _descCtrl.text = desc;
                setState(() => _coins = coins.clamp(5, 50));
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceContainerHigh, width: 2),
                ),
                child: Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              )),
                          if (desc.isNotEmpty)
                            Text(desc,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, color: AppTheme.outline,
                                )),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryFixed,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text('🪙 $coins',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: AppTheme.vibrantSecondary,
                          )),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
        if (_aiSuggestions == null && !_loadingAi)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Nhấn "Gợi ý ngay" để AI tự tạo nhiệm vụ phù hợp với con',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppTheme.outline,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceBright,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildSavedTemplates(),
                _buildQuickIdeas(),
                const SizedBox(height: 32),
                _buildCustomTaskForm(),
                const SizedBox(height: 24),
                _buildAiSuggestions(),
                const SizedBox(height: 32),
                _buildCategorySelector(),
                const SizedBox(height: 24),
                _buildRewardCard(),
                const SizedBox(height: 24),
                _buildDeadlineSection(),
              ],
            ),
          ),
          // Fixed Bottom Action Area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActionArea(),
          ),
        ],
      ),
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
        icon: const Icon(Icons.arrow_back, color: AppTheme.vibrantPrimary),
        onPressed: () => Navigator.pop(context),
      ),
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

  Widget _buildHeader() {
    final s = context.read<AppState>().strings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.createTaskTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          s.createTaskSub,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildSavedTemplates() {
    return Consumer<AppState>(
      builder: (context, app, _) {
        final templates = app.activeTemplates;
        if (templates.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.read<AppState>().strings.savedTemplates,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: templates.map((t) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => ParentTaskDetail(task: t),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryFixed,
                        borderRadius: BorderRadius.circular(20),
                        border: Border(
                          bottom: BorderSide(color: AppTheme.secondaryFixedDim, width: 3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(t.icon, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            t.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: AppTheme.onSecondaryFixed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildQuickIdeas() {
    final s = context.read<AppState>().strings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.quickIdeas,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _filteredIdeas.map((idea) {
            return GestureDetector(
              onTap: () {
                _titleCtrl.text = idea['title'] as String;
                setState(() {
                  _coins = idea['coins'] as int;
                  _category = idea['cat'] as String;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: idea['color'] as Color,
                  borderRadius: BorderRadius.circular(24),
                  border: Border(
                    bottom: BorderSide(color: idea['borderColor'] as Color, width: 4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(idea['icon'] as IconData, size: 18, color: idea['onColor'] as Color),
                    const SizedBox(width: 6),
                    Text(
                      idea['title'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: idea['onColor'] as Color,
                      ),
                    ),
                  ],
                ),
              ).animate().scale(curve: Curves.easeOutBack, delay: 50.ms),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomTaskForm() {
    final s = context.read<AppState>().strings;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.surfaceContainer, width: 2),
            boxShadow: [BoxShadow(color: AppTheme.vibrantPrimary.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.customTask, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                Text(s.taskNameLabel, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.outline)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleCtrl,
                  validator: Validators.taskTitle,
                  style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: s.taskNameHint,
                    hintStyle: const TextStyle(color: AppTheme.outlineVariant),
                    filled: true, fillColor: AppTheme.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 2)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 2)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.secondaryContainer, width: 2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(s.descriptionLabel, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.outline)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: s.descriptionHint,
                    hintStyle: const TextStyle(color: AppTheme.outlineVariant),
                    filled: true, fillColor: AppTheme.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 2)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 2)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.secondaryContainer, width: 2)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -20, right: -20,
          child: Container(width: 100, height: 100, decoration: BoxDecoration(color: AppTheme.secondaryFixed.withValues(alpha: 0.3), shape: BoxShape.circle)),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final s = context.read<AppState>().strings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.categorySection,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: _categories.map((cat) {
            final isSelected = _category == cat['id'];
            return GestureDetector(
              onTap: () => setState(() => _category = cat['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? (cat['bgColor'] as Color) : AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? (cat['color'] as Color) : AppTheme.surfaceContainer,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: cat['color'] as Color,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? (cat['color'] as Color) : (cat['bgColor'] as Color),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        cat['icon'] as IconData,
                        color: isSelected ? Colors.white : (cat['onColor'] as Color),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['id'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRewardCard() {
    return Transform.rotate(
      angle: 1 * 3.14159 / 180,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.secondaryContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.vibrantSecondary, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.vibrantSecondary,
              offset: Offset(0, 6),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REWARD',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSecondaryFixedVariant,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '$_coins Xu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.secondaryFixed, width: 4),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                    ],
                  ),
                  child: const Icon(Icons.monetization_on, color: AppTheme.vibrantSecondary, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppTheme.vibrantSecondary,
                thumbColor: AppTheme.vibrantSecondary,
                overlayColor: AppTheme.vibrantSecondary.withValues(alpha: 0.15),
                inactiveTrackColor: AppTheme.secondaryFixed,
                trackHeight: 8,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              ),
              child: Builder(
                builder: (context) {
                  final range = ageGroupCoinRanges[
                    context.watch<AppState>().childAge.ageGroup
                  ]!;
                  final clampedCoins = _coins.clamp(range.min, range.max);
                  if (clampedCoins != _coins) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => setState(() => _coins = clampedCoins),
                    );
                  }
                  return Slider(
                    value: clampedCoins.toDouble(),
                    min: range.min.toDouble(),
                    max: range.max.toDouble(),
                    divisions: (range.max - range.min) ~/ 5,
                    label: '$clampedCoins Xu',
                    onChanged: (v) => setState(() => _coins = v.round()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceContainer, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⏰', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Đặt thời hạn hoàn thành',
                  style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ),
              Switch(
                value: _deadlineEnabled,
                onChanged: (v) => setState(() {
                  _deadlineEnabled = v;
                  if (!v) { _dueDate = null; _hasPenalty = false; }
                }),
                activeThumbColor: AppTheme.vibrantPrimary,
                activeTrackColor: AppTheme.primaryFixed,
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tự động duyệt sau 10 lần',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    Text('Hệ thống tự xử lý sau 10 lần được duyệt',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Switch(
                value: _autoApproveEnabled,
                onChanged: (v) => setState(() => _autoApproveEnabled = v),
                activeThumbColor: AppTheme.vibrantPrimary,
                activeTrackColor: AppTheme.primaryFixed,
              ),
            ],
          ),
          if (_deadlineEnabled) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _quickChip('1 giờ', () => setState(() => _dueDate = DateTime.now().add(const Duration(hours: 1)))),
                _quickChip('Trước bữa tối', () => setState(() {
                  final now = DateTime.now();
                  _dueDate = DateTime(now.year, now.month, now.day, 18, 0);
                })),
                _quickChip('Trước khi ngủ', () => setState(() {
                  final now = DateTime.now();
                  _dueDate = DateTime(now.year, now.month, now.day, 21, 0);
                })),
                _quickChip('Ngày mai', () => setState(() {
                  final now = DateTime.now();
                  _dueDate = DateTime(now.year, now.month, now.day + 1, 8, 0);
                })),
                _quickChip('Tự chọn...', () async {
                  final picked = await showDateTimePicker(context);
                  if (picked != null) setState(() => _dueDate = picked);
                }),
              ],
            ),
            if (_dueDate != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.amber.withValues(alpha: 0.4))),
                child: Row(children: [
                  const Icon(Icons.access_time_rounded, color: AppTheme.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⏰ Con cần hoàn thành trước ${_formatDueDate(_dueDate!)}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF92400E), fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => setState(() => _hasPenalty = !_hasPenalty),
              child: Row(children: [
                Checkbox(
                  value: _hasPenalty,
                  onChanged: (v) => setState(() => _hasPenalty = v ?? false),
                  fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.selected)) return AppTheme.vibrantPrimary;
                    return null;
                  }),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text('Trừ 10% xu nếu trẻ bỏ task sau khi đã nhận',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _quickChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryFixed,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryFixedDim, width: 1.5),
        ),
        child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.vibrantPrimary)),
      ),
    );
  }

  String _formatDueDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dt.year, dt.month, dt.day);
    final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (dateOnly == today) return '$timeStr hôm nay';
    if (dateOnly == today.add(const Duration(days: 1))) return '$timeStr ngày mai';
    return '$timeStr ${dt.day}/${dt.month}';
  }

  Future<DateTime?> showDateTimePicker(BuildContext ctx) async {
    final date = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.0),
        ),
        child: child!,
      ),
    );
    if (date == null || !ctx.mounted) return null;
    final time = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.0),
        ),
        child: child!,
      ),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBright.withValues(alpha: 0.9),
        border: const Border(
          top: BorderSide(color: AppTheme.surfaceContainer, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: _isSubmitting ? null : _submit,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: AppTheme.vibrantPrimary,
              borderRadius: BorderRadius.circular(32),
              border: const Border(
                bottom: BorderSide(color: AppTheme.onPrimaryFixedVariant, width: 6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: _isSubmitting
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        context.read<AppState>().strings.createTaskBtn,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppState>();

    // Task limit gate for free users
    final activeCount = appState.pendingTasks.length;
    if (!appState.isPremium && activeCount >= appState.maxActiveTasks) {
      showPaywallDialog(context, feature: PaywallFeature.tasks);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      
      const categoryIcons = {
        'Việc nhà': '🏠',
        'Học tập': '📚',
        'Sức khỏe': '💪',
        'Sáng tạo': '🎨',
      };
      final String icon = categoryIcons[_category] ?? '📋';

      await appState.addTask(
        TaskModel(
          id: '',
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? 'Nhiệm vụ mới từ bố mẹ'
              : _descCtrl.text.trim(),
          coinReward: _coins,
          icon: icon,
          category: _category,
          dueDate: _deadlineEnabled ? _dueDate : null,
          hasPenalty: _deadlineEnabled && _hasPenalty,
          penaltyPercent: 10,
          autoApproveAfter: _autoApproveEnabled ? 10 : null,
        ),
      );
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      final s = context.read<AppState>().strings;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${s.errorPrefix}${e.toString()}'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    final app = context.read<AppState>();
    final s = app.strings;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 14),
            Text(s.taskCreatedTitle, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(
              s.taskCreatedMsg(app.childName, _coins),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () { Navigator.pop(ctx); Navigator.pop(context); },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.vibrantPrimary,
                  borderRadius: BorderRadius.circular(16),
                  border: const Border(bottom: BorderSide(color: AppTheme.onPrimaryFixedVariant, width: 4)),
                ),
                child: Center(child: Text(s.done, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
