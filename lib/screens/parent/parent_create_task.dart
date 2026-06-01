import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../utils/validators.dart';

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
  String _category = 'Housework';

  static final _quickIdeas = [
    {'title': 'Wash dishes', 'icon': Icons.local_laundry_service, 'coins': 15, 'cat': 'Housework', 'color': AppTheme.primaryFixed, 'onColor': AppTheme.onPrimaryFixed, 'borderColor': AppTheme.primaryFixedDim},
    {'title': 'Sweep house', 'icon': Icons.cleaning_services, 'coins': 10, 'cat': 'Housework', 'color': AppTheme.secondaryFixed, 'onColor': AppTheme.onSecondaryFixed, 'borderColor': AppTheme.secondaryFixedDim},
    {'title': 'Read books', 'icon': Icons.menu_book, 'coins': 20, 'cat': 'Study', 'color': AppTheme.tertiaryFixed, 'onColor': AppTheme.onTertiaryFixed, 'borderColor': AppTheme.tertiaryFixedDim},
    {'title': 'Exercise', 'icon': Icons.fitness_center, 'coins': 15, 'cat': 'Health', 'color': AppTheme.errorContainer, 'onColor': AppTheme.onErrorContainer, 'borderColor': Color(0xFFFFB4AB)},
    {'title': 'Water plants', 'icon': Icons.yard, 'coins': 10, 'cat': 'Housework', 'color': AppTheme.surfaceContainerHigh, 'onColor': AppTheme.vibrantPrimary, 'borderColor': AppTheme.outlineVariant},
    {'title': 'Fold clothes', 'icon': Icons.checkroom, 'coins': 15, 'cat': 'Housework', 'color': AppTheme.primaryFixed, 'onColor': AppTheme.onPrimaryFixed, 'borderColor': AppTheme.primaryFixedDim},
  ];

  static final _categories = [
    {'id': 'Housework', 'icon': Icons.home, 'color': AppTheme.vibrantPrimary, 'bgColor': AppTheme.primaryFixed, 'onColor': AppTheme.onPrimaryFixedVariant},
    {'id': 'Study', 'icon': Icons.school, 'color': AppTheme.vibrantTertiary, 'bgColor': AppTheme.tertiaryFixed, 'onColor': AppTheme.onTertiaryFixedVariant},
    {'id': 'Health', 'icon': Icons.favorite, 'color': Color(0xFF006B5F), 'bgColor': Color(0xFF78F8E4), 'onColor': Color(0xFF006B5F)},
    {'id': 'Creativity', 'icon': Icons.palette, 'color': AppTheme.vibrantSecondary, 'bgColor': AppTheme.secondaryFixed, 'onColor': AppTheme.onSecondaryFixedVariant},
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
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
                _buildQuickIdeas(),
                const SizedBox(height: 32),
                _buildCustomTaskForm(),
                const SizedBox(height: 32),
                _buildCategorySelector(),
                const SizedBox(height: 24),
                _buildRewardCard(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Mission!',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'What adventure awaits today?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickIdeas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Ideas',
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
          children: _quickIdeas.map((idea) {
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.surfaceContainer, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.vibrantPrimary.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Custom Task',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Task Name',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleCtrl,
                  validator: Validators.taskTitle,
                  style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'e.g. Clean the magical castle',
                    hintStyle: TextStyle(color: AppTheme.outlineVariant),
                    filled: true,
                    fillColor: AppTheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.secondaryContainer, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Description (Optional)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Any secret instructions?',
                    hintStyle: TextStyle(color: AppTheme.outlineVariant),
                    filled: true,
                    fillColor: AppTheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.secondaryContainer, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -20,
          right: -20,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.secondaryFixed.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
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
              child: Slider(
                value: _coins.toDouble(),
                min: 5,
                max: 50,
                divisions: 9,
                label: '$_coins Xu',
                onChanged: (v) => setState(() => _coins = v.round()),
              ),
            ),
          ],
        ),
      ),
    );
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
                        'Send Task',
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
    setState(() => _isSubmitting = true);
    try {
      final appState = context.read<AppState>();
      
      const categoryIcons = {
        'Housework': '🏠',
        'Study': '📚',
        'Health': '💪',
        'Creativity': '🎨',
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
          icon: icon, // note: Using emoji or icon logic as required by model
          category: _category,
        ),
      );
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    final childName = context.read<AppState>().childName;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 14),
            Text(
              'Đã giao việc!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$childName sẽ nhận được thông báo ngay!\n\nPhần thưởng: $_coins Xu 🪙',
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
            child: GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.vibrantPrimary,
                  borderRadius: BorderRadius.circular(16),
                  border: const Border(
                    bottom: BorderSide(color: AppTheme.onPrimaryFixedVariant, width: 4),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Xong! ✓',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 16,
                    ),
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
