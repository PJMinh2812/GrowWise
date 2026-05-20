import 'package:flutter/material.dart';
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
  String _category = 'Việc nhà';
  String? _selectedTemplate;

  static const _templates = [
    {'title': 'Rửa bát', 'icon': '🍽️', 'coins': 15, 'cat': 'Việc nhà'},
    {'title': 'Quét nhà', 'icon': '🧹', 'coins': 10, 'cat': 'Việc nhà'},
    {'title': 'Đọc sách 30 phút', 'icon': '📚', 'coins': 20, 'cat': 'Học tập'},
    {'title': 'Tập thể dục', 'icon': '🏃', 'coins': 15, 'cat': 'Sức khỏe'},
    {'title': 'Tưới cây', 'icon': '🌱', 'coins': 10, 'cat': 'Việc nhà'},
    {'title': 'Gấp quần áo', 'icon': '👕', 'coins': 15, 'cat': 'Việc nhà'},
    {'title': 'Học từ vựng', 'icon': '🔤', 'coins': 25, 'cat': 'Học tập'},
    {'title': 'Vẽ tranh', 'icon': '🎨', 'coins': 20, 'cat': 'Sáng tạo'},
  ];

  static const _categories = ['Việc nhà', 'Học tập', 'Sức khỏe', 'Sáng tạo'];
  static const _categoryIcons = {
    'Việc nhà': '🏠',
    'Học tập': '📚',
    'Sức khỏe': '🏃',
    'Sáng tạo': '🎨',
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childName = context.watch<AppState>().childName;
    return Theme(
      data: AppTheme.parentTheme(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
          title: Text(
            'Giao nhiệm vụ mới',
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
              // Template section
              _SectionLabel('📋 Chọn nhanh từ Template'),
              const SizedBox(height: 4),
              Text(
                'Kho template chuẩn Montessori / Nhật Bản',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppTheme.textHint,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _templates.map((t) {
                  final isSelected = _selectedTemplate == t['title'];
                  return GestureDetector(
                    onTap: () {
                      _titleCtrl.text = t['title'] as String;
                      setState(() {
                        _coins = t['coins'] as int;
                        _category = t['cat'] as String;
                        _selectedTemplate = t['title'] as String;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.gradientIndigo : null,
                        color: isSelected ? null : AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.indigo
                              : AppTheme.border,
                        ),
                        boxShadow: isSelected
                            ? AppTheme.shadowSm(AppTheme.indigo)
                            : AppTheme.cardShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t['icon'] as String,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            t['title'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppTheme.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'hoặc tạo riêng',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.textHint,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppTheme.border)),
                ],
              ),
              const SizedBox(height: 24),

              // Form
              _SectionLabel('✏️ Tạo nhiệm vụ riêng'),
              const SizedBox(height: 14),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _FieldLabel('Tên nhiệm vụ'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleCtrl,
                      validator: Validators.taskTitle,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        hintText: 'VD: Rửa bát sau bữa tối',
                        prefixIcon: Icon(
                          Icons.task_alt_outlined,
                          size: 20,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _FieldLabel('Mô tả chi tiết (tùy chọn)'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Hướng dẫn con cách làm...',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(
                            Icons.description_outlined,
                            size: 20,
                            color: AppTheme.textHint,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category selector
              _FieldLabel('Phân loại'),
              const SizedBox(height: 10),
              Row(
                children: _categories.map((cat) {
                  final isSelected = _category == cat;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _category = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppTheme.gradientIndigo : null,
                          color: isSelected ? null : AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.indigo : AppTheme.border,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _categoryIcons[cat]!,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              cat,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Coin reward
              Row(
                children: [
                  _FieldLabel('🪙 Phần thưởng'),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.gradientAmber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_coins Xu',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppTheme.indigo,
                  thumbColor: AppTheme.indigo,
                  overlayColor: AppTheme.indigo.withValues(alpha: 0.15),
                  inactiveTrackColor: AppTheme.indigoLight,
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
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientIndigo,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.shadowMd(AppTheme.indigo),
                  ),
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white),
                    label: Text(
                      'Giao việc cho $childName',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
      String icon = _categoryIcons[_category] ?? '📋';
      for (final t in _templates) {
        if (t['title'] == _titleCtrl.text.trim()) {
          icon = t['icon'] as String;
          break;
        }
      }
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
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppTheme.gradientIndigo,
                borderRadius: BorderRadius.circular(14),
              ),
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
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
                  'Xong! ✓',
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }
}
