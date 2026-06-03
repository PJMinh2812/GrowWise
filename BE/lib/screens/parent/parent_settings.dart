import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../login_screen.dart';

class ParentSettings extends StatelessWidget {
  const ParentSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Theme(
      data: AppTheme.parentTheme(),
      child: Scaffold(
        backgroundColor: AppTheme.surfaceBright,
        body: Consumer<AppState>(
          builder: (context, appState, _) {
            return ListView(
              padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 40),
              children: [
                // AppBar row
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'GrowWise',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.vibrantPrimary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.settings,
                        color: AppTheme.vibrantPrimary,
                        size: 26,
                      ),
                    ],
                  ),
                ),

                // Profile card
                _ProfileCard(
                  appState: appState,
                  onEdit: () => _editProfileDialog(context, appState),
                ),
                const SizedBox(height: 28),

                _SectionLabel('👦 Child Profile'),
                const SizedBox(height: 10),
                _Tile(
                  icon: Icons.person_outline_rounded,
                  title: 'Tên con',
                  subtitle: appState.childName.isEmpty
                      ? 'Chưa đặt tên'
                      : appState.childName,
                  onTap: () => _editChildNameDialog(context, appState),
                ),
                _Tile(
                  icon: Icons.cake_outlined,
                  title: 'Tuổi',
                  subtitle: '${appState.childAge} tuổi',
                  onTap: () => _editAgeDialog(context, appState),
                ),
                const SizedBox(height: 24),

                _SectionLabel('⚙️ App Settings'),
                const SizedBox(height: 10),
                _SwitchTile(
                  icon: Icons.notifications_outlined,
                  title: 'Thông báo',
                  subtitle: 'Nhắc nhở hàng ngày',
                  value: appState.notificationsEnabled,
                  onChanged: appState.updateNotifications,
                ),
                _Tile(
                  icon: Icons.language_outlined,
                  title: 'Ngôn ngữ',
                  subtitle: 'Tiếng Việt',
                  onTap: () => _showLanguageDialog(context),
                ),
                _Tile(
                  icon: Icons.palette_outlined,
                  title: 'Giao diện',
                  subtitle: 'Sáng',
                  onTap: () => _showThemeDialog(context),
                ),
                const SizedBox(height: 24),

                _SectionLabel('ℹ️ Info'),
                const SizedBox(height: 10),
                _Tile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'Hướng dẫn sử dụng',
                  onTap: () => _showHelpSheet(context),
                ),
                _Tile(
                  icon: Icons.info_outline_rounded,
                  title: 'About GrowWise',
                  subtitle: 'Version 1.0.0 · EXE101 Demo',
                  onTap: () => _showAboutDialog(context),
                ),
                const SizedBox(height: 36),

                // Log Out button
                GestureDetector(
                  onTap: () async {
                    await appState.logout();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFB8B8),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: Color(0xFFEF4444),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Đăng xuất',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
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
        decoration: const InputDecoration(hintText: 'Tuổi', suffixText: 'tuổi'),
      ),
      onSave: () {
        final age = int.tryParse(ctrl.text.trim());
        if (age != null && age > 0 && age < 18) appState.updateChildAge(age);
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
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.vibrantPrimary,
            ),
            child: Text(
              'Lưu',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (ctx) {
        final s = appState.strings;
        final currentLocale = appState.locale;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(s.languageDialogTitle, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () { appState.setLocale('vi'); Navigator.pop(ctx); },
                child: _LanguageOption(flag: '🇻🇳', name: 'Tiếng Việt', isSelected: currentLocale == 'vi'),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () { appState.setLocale('en'); Navigator.pop(ctx); },
                child: _LanguageOption(flag: '🇺🇸', name: 'English', isSelected: currentLocale == 'en'),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.vibrantPrimary),
                child: Text(s.close, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          '🎨 Giao diện',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              icon: Icons.light_mode_rounded,
              label: 'Sáng',
              isSelected: true,
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              icon: Icons.dark_mode_rounded,
              label: 'Tối',
              isSelected: false,
              badge: 'Sắp có',
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              icon: Icons.phone_android_rounded,
              label: 'Theo hệ thống',
              isSelected: false,
              badge: 'Sắp có',
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.vibrantPrimary,
              ),
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

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (ctx, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '❓ Hướng dẫn sử dụng',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _FaqItem(
              q: 'Cách tạo nhiệm vụ cho con?',
              a: 'Vào tab "Nhiệm vụ" → nhấn nút + góc phải → điền tên, mô tả, danh mục và số xu thưởng → nhấn Tạo nhiệm vụ.',
            ),
            _FaqItem(
              q: 'Con nhận xu khi nào?',
              a: 'Xu được cộng ngay sau khi bạn duyệt nhiệm vụ của con. Con nộp bằng chứng → bạn kiểm tra → nhấn Duyệt.',
            ),
            _FaqItem(
              q: 'Hũ tiền hoạt động như thế nào?',
              a: 'Mỗi khi con nhận xu, hệ thống tự chia: 40% vào hũ Tiết kiệm, 40% hũ Tiêu dùng, 20% hũ Sẻ chia. Giúp con học quản lý tài chính từ sớm.',
            ),
            _FaqItem(
              q: 'Ước mơ là gì?',
              a: 'Con đặt mục tiêu mua đồ vật yêu thích. Hệ thống hiện thanh tiến độ dựa trên xu đã tích lũy, giúp con có động lực hoàn thành nhiệm vụ.',
            ),
            _FaqItem(
              q: 'Huy hiệu được trao như thế nào?',
              a: 'Huy hiệu trao tự động khi con đạt mốc: hoàn thành 5/15 nhiệm vụ theo chủ đề, giữ streak 3/7/14/30 ngày, hoặc lên level mới.',
            ),
            _FaqItem(
              q: 'Làm sao đặt lại mật khẩu?',
              a: 'Ở màn hình đăng nhập → nhấn "Quên mật khẩu?" → nhập email → kiểm tra hộp thư và làm theo hướng dẫn.',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryFixed,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryFixedDim, width: 2),
              ),
              child: Row(
                children: [
                  const Text('📧', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Liên hệ hỗ trợ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'growwisesupport@gmail.com',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppTheme.vibrantPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.vibrantPrimary,
              ),
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

// ── Profile Card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final AppState appState;
  final VoidCallback onEdit;

  const _ProfileCard({required this.appState, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final name = appState.parentName.isEmpty
        ? 'Phụ huynh'
        : appState.parentName;
    final email = appState.parentEmail.isEmpty
        ? 'demo@growwise.app'
        : appState.parentEmail;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C5CBF), Color(0xFF5B5BD6)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                borderRadius: BorderRadius.circular(12),
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

// ── Section helpers ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
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
        activeTrackColor: AppTheme.vibrantPrimary,
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String name;
  final bool isSelected;

  const _LanguageOption({
    required this.flag,
    required this.name,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryFixed : AppTheme.surfaceBright,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.vibrantPrimary : AppTheme.surfaceContainerHigh,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle_rounded, color: AppTheme.vibrantPrimary, size: 20),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final String? badge;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryFixed : AppTheme.surfaceBright,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppTheme.vibrantPrimary
              : AppTheme.surfaceContainerHigh,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected ? AppTheme.vibrantPrimary : AppTheme.outline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: badge != null ? AppTheme.textHint : AppTheme.textPrimary,
              ),
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.vibrantPrimary,
              size: 20,
            )
          else if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppTheme.outline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBright,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceContainerHigh, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.q,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppTheme.outline,
                    size: 20,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                Text(
                  widget.a,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
