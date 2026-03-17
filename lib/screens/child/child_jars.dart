import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class ChildJars extends StatelessWidget {
  const ChildJars({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final spendJar = appState.spendJar;
        final saveJar = appState.saveJar;
        final shareJar = appState.shareJar;
        final total = spendJar + saveJar + shareJar;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Total
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text('💰', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    Text(
                      '$total Xu',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Tổng tài sản của con',
                      style: TextStyle(
                        color: AppTheme.textMedium,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3 Jars explanation
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '🏦 Phương pháp 3 Hũ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Chia Xu vào 3 hũ để học quản lý tài chính!',
                  style: TextStyle(color: AppTheme.textMedium, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),

              // Spend Jar
              _JarCard(
                emoji: '🛒',
                name: 'Hũ Tiêu dùng',
                description: 'Mua đồ chơi, quà tặng',
                amount: spendJar,
                total: total,
                color: const Color(0xFF42A5F5),
                bgColor: const Color(0xFFE3F2FD),
                onAdd: () => _transferDialog(context, 'Tiêu dùng'),
              ),
              const SizedBox(height: 12),

              // Save Jar
              _JarCard(
                emoji: '🏦',
                name: 'Hũ Tiết kiệm',
                description: 'Để dành cho mục tiêu lớn (lãi +5%/tháng)',
                amount: saveJar,
                total: total,
                color: const Color(0xFF66BB6A),
                bgColor: const Color(0xFFE8F5E9),
                onAdd: () => _transferDialog(context, 'Tiết kiệm'),
                interestRate: '+5%/tháng',
              ),
              const SizedBox(height: 12),

              // Share Jar
              _JarCard(
                emoji: '💝',
                name: 'Hũ Sẻ chia',
                description: 'Từ thiện, giúp đỡ người khác',
                amount: shareJar,
                total: total,
                color: const Color(0xFFEC407A),
                bgColor: const Color(0xFFFCE4EC),
                onAdd: () => _transferDialog(context, 'Sẻ chia'),
              ),
              const SizedBox(height: 24),

              // Pie chart visual (simple)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '📊 Phân bổ tài sản',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Simple bar chart
                    _BarRow(
                      '🛒 Tiêu dùng',
                      spendJar,
                      total,
                      const Color(0xFF42A5F5),
                    ),
                    const SizedBox(height: 8),
                    _BarRow(
                      '🏦 Tiết kiệm',
                      saveJar,
                      total,
                      const Color(0xFF66BB6A),
                    ),
                    const SizedBox(height: 8),
                    _BarRow(
                      '💝 Sẻ chia',
                      shareJar,
                      total,
                      const Color(0xFFEC407A),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _transferDialog(BuildContext context, String jarName) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Chuyển Xu vào hũ $jarName'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Số Xu trong hũ Tiêu dùng có thể chuyển:',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 4),
              Consumer<AppState>(
                builder: (context, appState, _) => Text(
                  '${appState.spendJar} Xu',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF42A5F5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Nhập số Xu';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Số Xu phải > 0';
                  final spend = context.read<AppState>().spendJar;
                  if (n > spend) return 'Không đủ Xu (có $spend)';
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Số Xu muốn chuyển',
                  prefixText: '🪙 ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Quick chips
              Wrap(
                spacing: 8,
                children: [5, 10, 20, 50].map((amount) {
                  return ActionChip(
                    label: Text('+$amount'),
                    onPressed: () {
                      amountController.text = amount.toString();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final amount = int.parse(amountController.text.trim());
              context.read<AppState>().transferToJar(jarName, amount);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Đã chuyển $amount Xu vào hũ $jarName!'),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            child: const Text('Chuyển'),
          ),
        ],
      ),
    );
  }
}

class _JarCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String description;
  final int amount;
  final int total;
  final Color color;
  final Color bgColor;
  final VoidCallback onAdd;
  final String? interestRate;

  const _JarCard({
    required this.emoji,
    required this.name,
    required this.description,
    required this.amount,
    required this.total,
    required this.color,
    required this.bgColor,
    required this.onAdd,
    this.interestRate,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (amount / total * 100).round() : 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontSize: 16,
                          ),
                        ),
                        if (interestRate != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              interestRate!,
                              style: TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amount Xu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: TextStyle(fontSize: 12, color: color),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: total > 0 ? amount / total : 0,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 32,
                child: FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Chuyển', style: TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int amount;
  final int total;
  final Color color;

  const _BarRow(this.label, this.amount, this.total, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? amount / total : 0,
              minHeight: 14,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$amount',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
