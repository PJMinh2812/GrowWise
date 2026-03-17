import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../login_screen.dart';
import '../forgot_password_screen.dart';

class ParentSettings extends StatelessWidget {
  const ParentSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.parentTheme(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Cài đặt')),
        body: Consumer<AppState>(
          builder: (context, appState, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile section
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
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.parentBlueLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            '👨‍👩‍👧',
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.parentName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appState.parentEmail,
                              style: const TextStyle(
                                color: AppTheme.textMedium,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _editProfileDialog(context, appState),
                        icon: const Icon(
                          Icons.edit,
                          color: AppTheme.parentBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Child info
                const Text(
                  '👦 Hồ sơ con',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.person,
                  title: 'Tên con',
                  subtitle: appState.childName,
                  onTap: () => _editChildNameDialog(context, appState),
                ),
                _SettingsTile(
                  icon: Icons.cake,
                  title: 'Tuổi',
                  subtitle: '${appState.childAge} tuổi',
                  onTap: () => _editAgeDialog(context, appState),
                ),
                const SizedBox(height: 24),

                // App settings
                const Text(
                  '⚙️ Cài đặt ứng dụng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    secondary: const Icon(
                      Icons.notifications,
                      color: AppTheme.parentBlue,
                    ),
                    title: const Text(
                      'Thông báo',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      appState.notificationsEnabled ? 'Đang bật' : 'Đang tắt',
                      style: const TextStyle(fontSize: 13),
                    ),
                    value: appState.notificationsEnabled,
                    onChanged: (v) => appState.updateNotifications(v),
                    activeTrackColor: AppTheme.parentBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                _SettingsTile(
                  icon: Icons.language,
                  title: 'Ngôn ngữ',
                  subtitle: 'Tiếng Việt',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.shield,
                  title: 'Bảo mật',
                  subtitle: 'Đổi mật khẩu',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // About
                const Text(
                  'ℹ️ Thông tin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.info,
                  title: 'Về GrowWise',
                  subtitle: 'Version 1.0.0 - EXE101 Demo',
                  onTap: () => _showAboutDialog(context),
                ),
                _SettingsTile(
                  icon: Icons.help,
                  title: 'Hướng dẫn sử dụng',
                  subtitle: 'Xem tutorial',
                  onTap: () {},
                ),
                const SizedBox(height: 32),

                // Logout
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await appState.logout();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Đăng xuất',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _editProfileDialog(BuildContext context, AppState appState) {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: appState.parentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đổi tên hiển thị'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            validator: Validators.name,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Tên của bạn',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              appState.updateParentName(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _editChildNameDialog(BuildContext context, AppState appState) {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: appState.childName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đổi tên con'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            validator: Validators.name,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Tên con',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              appState.updateChildName(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _editAgeDialog(BuildContext context, AppState appState) {
    final controller = TextEditingController(
      text: appState.childAge.toString(),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đổi tuổi con'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Tuổi',
            suffixText: 'tuổi',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final age = int.tryParse(controller.text.trim());
              if (age != null && age > 0 && age < 18) {
                appState.updateChildAge(age);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🌱', style: TextStyle(fontSize: 56)),
            SizedBox(height: 12),
            Text(
              'GrowWise',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('Version 1.0.0', style: TextStyle(color: AppTheme.textMedium)),
            SizedBox(height: 16),
            Text(
              'Nền tảng EdTech/Family-Tech giáo dục tài chính cho trẻ 6-12 tuổi.\n\nEXE101 Project - FPT University',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.parentBlue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textLight),
        onTap: onTap,
      ),
    );
  }
}
