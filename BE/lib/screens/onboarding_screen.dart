import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'setup_screen.dart';
import 'role_selection.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _contentCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _pageData = [
    _PageData(
      emoji: '🌱',
      title: 'Chào mừng đến GrowWise!',
      description: 'Nền tảng giáo dục tài chính cho trẻ 6–12 tuổi. Cùng con học quản lý tiền thông qua trò chơi!',
      gradient: [Color(0xFF3DBE6E), Color(0xFF22A65B)],
      bgColor: Color(0xFFE8F8EF),
    ),
    _PageData(
      emoji: '🏦',
      title: 'Phương pháp 3 Hũ',
      description: 'Tiêu dùng • Tiết kiệm • Sẻ chia\nCon học phân chia tài chính từ nhỏ với phương pháp 3 hũ kinh điển.',
      gradient: [Color(0xFF5B5BD6), Color(0xFF4040C0)],
      bgColor: Color(0xFFEEEEFA),
    ),
    _PageData(
      emoji: '🗺️',
      title: 'Nhiệm vụ Gamification',
      description: 'Bố mẹ giao việc nhà → Con hoàn thành → Nhận Xu thưởng! Học trách nhiệm qua trò chơi thú vị.',
      gradient: [Color(0xFFF59E0B), Color(0xFFD97706)],
      bgColor: Color(0xFFFEF3C7),
    ),
    _PageData(
      emoji: '🤖',
      title: 'AI Bonding Reminder',
      description: 'AI nhắc nhở bố mẹ khen con, gửi Voice Note. Tăng kết nối tình cảm gia đình mỗi ngày.',
      gradient: [Color(0xFFEC4899), Color(0xFFDB2777)],
      bgColor: Color(0xFFFCE7F3),
    ),
    _PageData(
      emoji: '⭐',
      title: 'Dream Jar',
      description: 'Con đặt mục tiêu mua đồ yêu thích. Tích Xu từ nhiệm vụ để đạt ước mơ!',
      gradient: [Color(0xFFA855F7), Color(0xFF7C3AED)],
      bgColor: Color(0xFFF3E8FF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));
    _contentCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() => _currentPage = i);
    _contentCtrl.forward(from: 0);
  }

  void _nextPage() {
    if (_currentPage < _pageData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    final appState = context.read<AppState>();
    appState.completeOnboarding();
    final destination = appState.hasChild
        ? const RoleSelectionScreen()
        : const SetupScreen();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx, a1, a2) => destination,
        transitionsBuilder: (ctx, a1, a2, child) =>
            FadeTransition(opacity: a1, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pageData[_currentPage];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: page.bgColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _DotIndicator(
                      count: _pageData.length,
                      current: _currentPage,
                      gradient: page.gradient,
                    ),
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        'Bỏ qua',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pageData.length,
                  itemBuilder: (context, i) => _OnboardingPageView(
                    data: _pageData[i],
                    fadeAnim: _fadeAnim,
                    slideAnim: _slideAnim,
                  ),
                ),
              ),

              // Bottom CTA
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: page.gradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: page.gradient.first.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: FilledButton(
                          onPressed: _nextPage,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _currentPage == _pageData.length - 1
                                ? 'Bắt đầu ngay! 🚀'
                                : 'Tiếp theo →',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${_currentPage + 1} / ${_pageData.length}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppTheme.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageData {
  final String emoji;
  final String title;
  final String description;
  final List<Color> gradient;
  final Color bgColor;

  const _PageData({
    required this.emoji,
    required this.title,
    required this.description,
    required this.gradient,
    required this.bgColor,
  });
}

class _OnboardingPageView extends StatelessWidget {
  final _PageData data;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;

  const _OnboardingPageView({
    required this.data,
    required this.fadeAnim,
    required this.slideAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: FadeTransition(
        opacity: fadeAnim,
        child: SlideTransition(
          position: slideAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji bubble
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      data.gradient.first.withValues(alpha: 0.15),
                      data.gradient.last.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: data.gradient.first.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    data.emoji,
                    style: const TextStyle(fontSize: 72),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Gradient title
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: data.gradient,
                ).createShader(bounds),
                child: Text(
                  data.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                data.description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  height: 1.7,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int count;
  final int current;
  final List<Color> gradient;

  const _DotIndicator({
    required this.count,
    required this.current,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(colors: gradient)
                : null,
            color: isActive ? null : AppTheme.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
