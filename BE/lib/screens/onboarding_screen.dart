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

  static const _pageEmojis = ['🌱', '🏦', '🗺️', '🤖', '⭐'];
  static const _pageGradients = [
    [Color(0xFF3DBE6E), Color(0xFF22A65B)],
    [Color(0xFF5B5BD6), Color(0xFF4040C0)],
    [Color(0xFFF59E0B), Color(0xFFD97706)],
    [Color(0xFFEC4899), Color(0xFFDB2777)],
    [Color(0xFFA855F7), Color(0xFF7C3AED)],
  ];
  static const _pageBgColors = [
    Color(0xFFE8F8EF),
    Color(0xFFEEEEFA),
    Color(0xFFFEF3C7),
    Color(0xFFFCE7F3),
    Color(0xFFF3E8FF),
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
    if (_currentPage < _pageEmojis.length - 1) {
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
    final s = context.watch<AppState>().strings;
    final gradient = _pageGradients[_currentPage];
    final bgColor = _pageBgColors[_currentPage];

    final titles = [s.onb1Title, s.onb2Title, s.onb3Title, s.onb4Title, s.onb5Title];
    final descs  = [s.onb1Desc,  s.onb2Desc,  s.onb3Desc,  s.onb4Desc,  s.onb5Desc];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: bgColor,
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
                      count: _pageEmojis.length,
                      current: _currentPage,
                      gradient: gradient,
                    ),
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        s.skip,
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
                  itemCount: _pageEmojis.length,
                  itemBuilder: (context, i) => _OnboardingPageView(
                    emoji: _pageEmojis[i],
                    title: titles[i],
                    description: descs[i],
                    gradient: _pageGradients[i],
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
                            colors: gradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: gradient.first.withValues(alpha: 0.4),
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
                            _currentPage == _pageEmojis.length - 1
                                ? s.getStarted
                                : s.next,
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
                      '${_currentPage + 1} / ${_pageEmojis.length}',
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

class _OnboardingPageView extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final List<Color> gradient;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;

  const _OnboardingPageView({
    required this.emoji,
    required this.title,
    required this.description,
    required this.gradient,
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
                      gradient.first.withValues(alpha: 0.15),
                      gradient.last.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: gradient.first.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 72),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Gradient title
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: gradient,
                ).createShader(bounds),
                child: Text(
                  title,
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
                description,
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
