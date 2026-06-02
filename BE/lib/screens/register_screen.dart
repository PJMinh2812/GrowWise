import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import 'login_screen.dart';
import 'setup_screen.dart';
import 'role_selection.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _agreedToTerms = false;
  StreamSubscription<AuthState>? _authSub;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    final appState = context.read<AppState>();
    if (!appState.isDemoMode) {
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((
        data,
      ) async {
        if (!mounted) return;
        if (data.event == AuthChangeEvent.signedIn) {
          final appState = context.read<AppState>();
          await appState.initializeAfterOAuth();
          if (!mounted) return;
          final dest = appState.hasChild
              ? const RoleSelectionScreen()
              : const SetupScreen();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => dest),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _authSub?.cancel();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _showError('Vui lòng đồng ý với điều khoản sử dụng');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await context.read<AppState>().register(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        fullName: _nameCtrl.text.trim(),
      );
      if (!mounted) return;
      // Nếu Supabase tắt email confirmation → user đã auto login,
      // authSub listener sẽ tự navigate. Chỉ show dialog khi chưa login.
      if (Supabase.instance.client.auth.currentUser == null) {
        _showEmailSentDialog();
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      String msg;
      switch (e.statusCode) {
        case '422':
          msg = 'Email đã được đăng ký. Vui lòng dùng email khác.';
          break;
        case '429':
          msg = 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
          break;
        default:
          msg = e.message;
      }
      _showError(msg);
    } catch (e) {
      if (!mounted) return;
      _showError('Lỗi đăng ký: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFEF4444)),
    );
  }

  void _showEmailSentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📧', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 14),
            Text(
              'Xác nhận email',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Chúng tôi đã gửi link xác nhận đến\n${_emailCtrl.text.trim()}\n\nVui lòng kiểm tra email và nhấn vào link xác nhận.',
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
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppTheme.gradientGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
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
                  'Đến trang Đăng nhập',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 260,
            decoration: const BoxDecoration(gradient: AppTheme.gradientGreen),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text('🌱', style: TextStyle(fontSize: 34)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tạo tài khoản',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: AppTheme.shadowLg(Colors.black),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('Họ và tên'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _nameCtrl,
                                textCapitalization: TextCapitalization.words,
                                validator: Validators.name,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: const InputDecoration(
                                  hintText: 'Nguyễn Văn Minh',
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                    size: 20,
                                    color: AppTheme.textHint,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              _Label('Email'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.email,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: const InputDecoration(
                                  hintText: 'email@example.com',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    size: 20,
                                    color: AppTheme.textHint,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              _Label('Mật khẩu'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscurePass,
                                validator: Validators.password,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  hintText: 'Tối thiểu 6 ký tự',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    size: 20,
                                    color: AppTheme.textHint,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePass
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                      color: AppTheme.textHint,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscurePass = !_obscurePass,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              _Label('Xác nhận mật khẩu'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _confirmCtrl,
                                obscureText: _obscureConfirm,
                                validator: Validators.confirmPassword(
                                  _passCtrl.text,
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  hintText: 'Nhập lại mật khẩu',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    size: 20,
                                    color: AppTheme.textHint,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirm
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                      color: AppTheme.textHint,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Terms
                              GestureDetector(
                                onTap: () => setState(
                                  () => _agreedToTerms = !_agreedToTerms,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Checkbox(
                                        value: _agreedToTerms,
                                        onChanged: (v) => setState(
                                          () => _agreedToTerms = v ?? false,
                                        ),
                                        activeColor: AppTheme.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Tôi đồng ý với Điều khoản sử dụng và Chính sách bảo mật',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Register button
                              SizedBox(
                                width: double.infinity,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.gradientGreen,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow:
                                        AppTheme.shadowMd(AppTheme.green),
                                  ),
                                  child: FilledButton(
                                    onPressed: _isLoading ? null : _register,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Tạo tài khoản',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Divider
                              Row(
                                children: [
                                  const Expanded(
                                      child: Divider(color: AppTheme.border)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(
                                      'hoặc',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: AppTheme.textHint),
                                    ),
                                  ),
                                  const Expanded(
                                      child: Divider(color: AppTheme.border)),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Google button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: _isGoogleLoading
                                      ? null
                                      : () async {
                                          setState(
                                              () => _isGoogleLoading = true);
                                          try {
                                            await context
                                                .read<AppState>()
                                                .loginWithGoogle();
                                          } catch (e) {
                                            if (mounted) {
                                              _showError(
                                                  'Lỗi Google: ${e.toString()}');
                                            }
                                          } finally {
                                            if (mounted) {
                                              setState(
                                                () => _isGoogleLoading = false,
                                              );
                                            }
                                          }
                                        },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side: const BorderSide(
                                        color: AppTheme.border),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _isGoogleLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                boxShadow: AppTheme.shadowSm(
                                                    Colors.black),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  'G',
                                                  style: TextStyle(
                                                    color: Color(0xFF4285F4),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Tiếp tục với Google',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Login link
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Đã có tài khoản? ',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const LoginScreen()),
                                      ),
                                      child: Text(
                                        'Đăng nhập',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
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

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

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
