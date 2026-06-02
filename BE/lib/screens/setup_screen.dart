import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import 'role_selection.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController(text: '8');
  String _selectedEmoji = '👦';
  bool _isLoading = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _emojiOptions = ['👦', '👧', '🧒', '👶', '🐣', '🦊', '🐱', '🐶'];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _createChild() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final appState = context.read<AppState>();
      await appState.createChild(
        name: _nameCtrl.text.trim(),
        age: int.parse(_ageCtrl.text.trim()),
        avatarEmoji: _selectedEmoji,
      );
      await appState.initialize();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (ctx, a1, a2) => const RoleSelectionScreen(),
          transitionsBuilder: (ctx, a1, a2, child) =>
              FadeTransition(opacity: a1, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Hero top
          Positioned(
            top: 0, left: 0, right: 0,
            height: 260,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.gradientGreen,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('👨‍👩‍👧', style: TextStyle(fontSize: 44)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Thêm hồ sơ con',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Cùng con bắt đầu hành trình GrowWise!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: -30, right: -30,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 60, left: -20,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Form card
          Positioned(
            top: 226, left: 20, right: 20, bottom: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppTheme.shadowMd(AppTheme.green),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar picker
                          _FieldLabel('Chọn avatar cho con'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _emojiOptions.map((emoji) {
                              final isSelected = emoji == _selectedEmoji;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedEmoji = emoji),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? AppTheme.gradientGreen
                                        : null,
                                    color: isSelected ? null : AppTheme.bg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.green
                                          : AppTheme.border,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? AppTheme.shadowSm(AppTheme.green)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),

                          // Selected preview
                          if (_nameCtrl.text.isNotEmpty || _selectedEmoji.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12,
                              ),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: AppTheme.greenLight,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.green.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _selectedEmoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _nameCtrl.text.isEmpty
                                            ? 'Tên con sẽ hiện ở đây'
                                            : _nameCtrl.text,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${_ageCtrl.text.isEmpty ? '?' : _ageCtrl.text} tuổi',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          // Name field
                          _FieldLabel('Tên con'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameCtrl,
                            textCapitalization: TextCapitalization.words,
                            validator: Validators.name,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'VD: Tôm, Bống, Bi...',
                              prefixIcon: Icon(
                                Icons.child_care_rounded,
                                size: 20,
                                color: AppTheme.textHint,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Age field
                          _FieldLabel('Tuổi con'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _ageCtrl,
                            keyboardType: TextInputType.number,
                            validator: Validators.age,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'VD: 8',
                              prefixIcon: Icon(
                                Icons.cake_rounded,
                                size: 20,
                                color: AppTheme.textHint,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Submit
                          SizedBox(
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppTheme.gradientGreen,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppTheme.shadowMd(AppTheme.green),
                              ),
                              child: FilledButton.icon(
                                onPressed: _isLoading ? null : _createChild,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 20, height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        '🚀',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                label: Text(
                                  'Bắt đầu hành trình!',
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
                ),
              ),
            ),
          ),
        ],
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
