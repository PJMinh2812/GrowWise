import 'package:flutter/material.dart';
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
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSubmitting = false;
  int _selectedCoins = 15;
  String _selectedCategory = 'Việc nhà';

  final _templates = [
    {'title': 'Rửa bát', 'icon': '🍽️', 'coins': 15, 'cat': 'Việc nhà'},
    {'title': 'Quét nhà', 'icon': '🧹', 'coins': 10, 'cat': 'Việc nhà'},
    {'title': 'Đọc sách 30 phút', 'icon': '📚', 'coins': 20, 'cat': 'Học tập'},
    {'title': 'Tập thể dục', 'icon': '🏃', 'coins': 15, 'cat': 'Sức khỏe'},
    {'title': 'Tưới cây', 'icon': '🌱', 'coins': 10, 'cat': 'Việc nhà'},
    {'title': 'Gấp quần áo', 'icon': '👕', 'coins': 15, 'cat': 'Việc nhà'},
    {'title': 'Học từ vựng', 'icon': '🔤', 'coins': 25, 'cat': 'Học tập'},
    {'title': 'Vẽ tranh', 'icon': '🎨', 'coins': 20, 'cat': 'Sáng tạo'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.parentTheme(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Giao nhiệm vụ mới')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Template section
              const Text(
                '📋 Chọn nhanh từ Template',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kho template chuẩn Montessori / Nhật Bản',
                style: TextStyle(fontSize: 13, color: AppTheme.textMedium),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _templates.map((t) {
                  return ActionChip(
                    avatar: Text(
                      t['icon'] as String,
                      style: const TextStyle(fontSize: 16),
                    ),
                    label: Text(t['title'] as String),
                    onPressed: () {
                      _titleController.text = t['title'] as String;
                      _selectedCoins = t['coins'] as int;
                      _selectedCategory = t['cat'] as String;
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Custom task form
              const Text(
                '✏️ Hoặc tạo nhiệm vụ riêng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      validator: Validators.taskTitle,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: 'Tên nhiệm vụ',
                        hintText: 'VD: Rửa bát sau bữa tối',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.task),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Mô tả chi tiết',
                        hintText: 'Hướng dẫn con cách làm...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Phân loại',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: ['Việc nhà', 'Học tập', 'Sức khỏe', 'Sáng tạo']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 20),

              // Coin reward slider
              const Text(
                '🪙 Phần thưởng Xu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _selectedCoins.toDouble(),
                      min: 5,
                      max: 50,
                      divisions: 9,
                      label: '$_selectedCoins Xu',
                      onChanged: (v) =>
                          setState(() => _selectedCoins = v.round()),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.coinGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_selectedCoins 🪙',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppTheme.coinGold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Submit
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : () async {
                    if (!_formKey.currentState!.validate()) return;

                    setState(() => _isSubmitting = true);
                    try {
                      final appState = context.read<AppState>();
                      final iconMap = {
                        'Việc nhà': '🏠',
                        'Học tập': '📚',
                        'Sức khỏe': '🏃',
                        'Sáng tạo': '🎨',
                      };
                      String taskIcon = iconMap[_selectedCategory] ?? '📋';
                      for (final t in _templates) {
                        if (t['title'] == _titleController.text) {
                          taskIcon = t['icon'] as String;
                          break;
                        }
                      }
                      await appState.addTask(
                        TaskModel(
                          id: '',
                          title: _titleController.text.trim(),
                          description: _descController.text.trim().isEmpty
                              ? 'Nhiệm vụ mới từ bố mẹ'
                              : _descController.text.trim(),
                          coinReward: _selectedCoins,
                          icon: taskIcon,
                          category: _selectedCategory,
                        ),
                      );
                      if (!mounted) return;
                      _showSuccessDialog();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
                      );
                    } finally {
                      if (mounted) setState(() => _isSubmitting = false);
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Giao nhiệm vụ cho ${context.watch<AppState>().childName}',
                        ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  void _showSuccessDialog() {
    final childName = context.read<AppState>().childName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            const Text(
              'Đã giao nhiệm vụ!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '"${_titleController.text}" đã được gửi đến $childName.\nPhần thưởng: $_selectedCoins Xu',
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
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Xong'),
            ),
          ),
        ],
      ),
    );
  }
}
