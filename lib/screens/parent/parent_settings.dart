import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        appBar: AppBar(
          title: Text(
            'Cài đặt',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          backgroundColor: AppTheme.surface,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        ),
        body: Consumer<AppState>(
          builder: (context, appState, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                // Profile card
                _ProfileCard(appState: appState, onEdit: () => _editProfileDialog(context, appState)),
                const SizedBox(height: 28),

                _SectionLabel('👦 Hồ sơ con'),
                const SizedBox(height: 10),
                _Tile(
                  icon: Icons.person_outline_rounded,
                  title: 'Tên con',
                  subtitle: appState.childName,
                  onTap: () => _editChildNameDialog(context, appState),
                ),
                _Tile(
                  icon: Icons.cake_outlined,
                  title: 'Tuổi',
                  subtitle: '${appState.childAge} tuổi',
                  onTap: () => _editAgeDialog(context, appState),
                ),
                const SizedBox(height: 24),

                _SectionLabel('⚙️ Cài đặt ứng dụng'),
                const SizedBox(height: 10),
                _SwitchTile(
                  icon: Icons.notifications_outlined,
                  title: 'Thông báo',
                  subtitle: appState.notificationsEnabled ? 'Đang bật' : 'Đang tắt',
                  value: appState.notificationsEnabled,
                  onChanged: appState.updateNotifications,
                ),
                _Tile(
                  icon: Icons.language_outlined,
                  title: 'Ngôn ngữ',
                  subtitle: 'Tiếng Việt',
                  onTap: () => _showComingSoon(context),
                ),
                _Tile(
                  icon: Icons.shield_outlined,
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

                _SectionLabel('ℹ️ Thông tin'),
                const SizedBox(height: 10),
                _Tile(
                  icon: Icons.info_outline_rounded,
                  title: 'Về GrowWise',
                  subtitle: 'Version 1.0.0 · EXE101 Demo',
                  onTap: () => _showAboutDialog(context),
                ),
                _Tile(
                  icon: Icons.help_outline_rounded,
                  title: 'Hướng dẫn sử dụng',
                  subtitle: 'Xem tutorial',
                  onTap: () => _showComingSoon(context),
                ),
                const SizedBox(height: 36),

                // Logout button
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
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFEF4444),
                    ),
                    label: Text(
                      'Đăng xuất',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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
    final ctrl = TextEditingController(text: appState.parentName);
    _showFormDialog(
      context,
      title: '✏️ Đổi tên hiển thị',
      child: Form(
        key: formKey,
        child: TextFormField(
          controller: ctrl,
          validator: Validators.name,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(hintText: 'Tên của bạn'),
        ),
      ),
      onSave: () {
        if (!formKey.currentState!.validate()) return false;
        appState.updateParentName(ctrl.text.trim());
        return true;
      },
    );
  }

  void _editChildNameDialog(BuildContext context, AppState appState) {
    final formKey = GlobalKey<FormState>();
    final ctrl = TextEditingController(text: appState.childName);
    _showFormDialog(
      context,
      title: '✏️ Đổi tên con',
      child: Form(
        key: formKey,
        child: TextFormField(
          controller: ctrl,
          validator: Validators.name,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(hintText: 'Tên con'),
        ),
      ),
      onSave: () {
        if (!formKey.currentState!.validate()) return false;
        appState.updateChildName(ctrl.text.trim());
        return true;
      },
    );
  }

  void _editAgeDialog(BuildContext context, AppState appState) {
    final ctrl = TextEditingController(text: appState.childAge.toString());
    _showFormDialog(
      context,
      title: '🎂 Đổi tuổi con',
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Tuổi',
          suffixText: 'tuổi',
        ),
      ),
      onSave: () {
        final age = int.tryParse(ctrl.text.trim());
        if (age != null && age > 0 && age < 18) {
          appState.updateChildAge(age);
        }
        return true;
      },
    );
  }

  void _showFormDialog(
    BuildContext context, {
    required String title,
    required Widget child,
    required bool Function() onSave,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: child,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Hủy',
              style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () {
              if (onSave()) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.indigo),
            child: Text(
              'Lưu',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Tính năng đang được hoàn thiện, sẽ sớm có mặt!'),
        backgroundColor: AppTheme.indigo,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'GrowWise',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.plusJakartaSans(color: AppTheme.textHint),
            ),
            const SizedBox(height: 16),
            Text(
              'Nền tảng EdTech/Family-Tech giáo dục tài chính cho trẻ 6–12 tuổi.\n\nEXE101 Project · FPT University',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                height: 1.6,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.indigo),
              child: Text(
                'Đóng',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final AppState appState;
  final VoidCallback onEdit;

  const _ProfileCard({required this.appState, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.gradientIndigo,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.shadowMd(AppTheme.indigo),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text('👨‍👩‍👧', style: TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.parentName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  appState.parentEmail,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 20,
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

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.indigoLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.indigo, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppTheme.textHint,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.textHint,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: SwitchListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        secondary: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.indigoLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.indigo, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppTheme.textHint,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppTheme.indigo,
      ),
    );
  }
}
