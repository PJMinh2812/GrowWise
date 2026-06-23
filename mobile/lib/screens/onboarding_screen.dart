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

  static const _pageEmojis = ['🌱', '🏦', '🗺️', '🤖', '⭐', '🏺'];
  static const _pageGradients = [
    [Color(0xFF3DBE6E), Color(0xFF22A65B)],
    [Color(0xFF5B5BD6), Color(0xFF4040C0)],
    [Color(0xFFF59E0B), Color(0xFFD97706)],
    [Color(0xFFEC4899), Color(0xFFDB2777)],
    [Color(0xFFA855F7), Color(0xFF7C3AED)],
    [Color(0xFF3DBE6E), Color(0xFF00A859)],
  ];
  static const _pageBgColors = [
    Color(0xFFE8F8EF),
    Color(0xFFEEEEFA),
    Color(0xFFFEF3C7),
    Color(0xFFFCE7F3),
    Color(0xFFF3E8FF),
    Color(0xFFF0FFF5),
  ];

  String _dreamEmoji = '🧸';
  final _dreamNameCtrl = TextEditingController();
  final _dreamPriceCtrl = TextEditingController();

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
    _dreamNameCtrl.dispose();
    _dreamPriceCtrl.dispose();
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
      // Saving goal step — save dream if user entered data
      final name = _dreamNameCtrl.text.trim();
      final price = int.tryParse(_dreamPriceCtrl.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
      if (name.isNotEmpty && price > 0) {
        context.read<AppState>().addDream(name, price, _dreamEmoji);
      }
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
                  itemBuilder: (context, i) {
                    if (i == 5) {
                      return _SavingGoalPage(
                        selectedEmoji: _dreamEmoji,
                        onEmojiChanged: (e) => setState(() => _dreamEmoji = e),
                        nameCtrl: _dreamNameCtrl,
                        priceCtrl: _dreamPriceCtrl,
                        gradient: _pageGradients[5],
                        fadeAnim: _fadeAnim,
                        slideAnim: _slideAnim,
                      );
                    }
                    return _OnboardingPageView(
                      emoji: _pageEmojis[i],
                      title: titles[i],
                      description: descs[i],
                      gradient: _pageGradients[i],
                      fadeAnim: _fadeAnim,
                      slideAnim: _slideAnim,
                    );
                  },
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
                                ? 'Bắt đầu hành trình! 🚀'
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

class _SavingGoalPage extends StatefulWidget {
  final String selectedEmoji;
  final ValueChanged<String> onEmojiChanged;
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final List<Color> gradient;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;

  const _SavingGoalPage({
    required this.selectedEmoji,
    required this.onEmojiChanged,
    required this.nameCtrl,
    required this.priceCtrl,
    required this.gradient,
    required this.fadeAnim,
    required this.slideAnim,
  });

  @override
  State<_SavingGoalPage> createState() => _SavingGoalPageState();
}

class _SavingGoalPageState extends State<_SavingGoalPage> {
  static const _emojis = ['🧸', '🎮', '📚', '🚲', '👟', '🎨', '🎯', '🎵', '⚽'];

  @override
  void initState() {
    super.initState();
    widget.priceCtrl.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.priceCtrl.removeListener(_rebuild);
    super.dispose();
  }

  int? get _estimateWeeks {
    final raw = widget.priceCtrl.text.replaceAll('.', '').replaceAll(',', '');
    final price = int.tryParse(raw);
    if (price == null || price <= 0) return null;
    const coinsPerWeek = 40 * 7; // 2 tasks/day × 20 xu × 7 days
    return (price / coinsPerWeek).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.fadeAnim,
      child: SlideTransition(
        position: widget.slideAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Column(
            children: [
              const Text('🏺', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 12),
              ShaderMask(
                shaderCallback: (b) => LinearGradient(colors: widget.gradient).createShader(b),
                child: Text(
                  'Con muốn dành dụm\nđể mua gì? 🌟',
                  style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy đặt một ước mơ — GrowWise sẽ giúp con đạt được!',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppTheme.green.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chọn biểu tượng:',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 52,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _emojis.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final selected = widget.selectedEmoji == _emojis[i];
                          return GestureDetector(
                            onTap: () => widget.onEmojiChanged(_emojis[i]),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: selected ? AppTheme.greenLight : AppTheme.bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: selected ? AppTheme.green : AppTheme.border, width: selected ? 2 : 1),
                              ),
                              child: Center(child: Text(_emojis[i], style: const TextStyle(fontSize: 24))),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: widget.nameCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Tên món đồ mơ ước...',
                        filled: true, fillColor: AppTheme.bg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: widget.gradient.first, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: widget.priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Mục tiêu... xu',
                        suffixText: 'xu',
                        filled: true, fillColor: AppTheme.bg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: widget.gradient.first, width: 2)),
                      ),
                    ),
                    if (_estimateWeeks != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: AppTheme.greenLight, borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '≈ $_estimateWeeks tuần nếu con làm 2 nhiệm vụ/ngày',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.green, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ]),
                      ),
                    ],
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
