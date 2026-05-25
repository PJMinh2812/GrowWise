import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'role_selection.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _rotateCtrl;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 3200), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final appState = context.read<AppState>();
    Widget destination;
    if (!appState.hasSeenOnboarding) {
      destination = const OnboardingScreen();
    } else if (appState.isLoggedIn) {
      destination = const RoleSelectionScreen();
    } else {
      destination = const LoginScreen();
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx, a1, a2) => destination,
        transitionsBuilder: (ctx, a1, a2, child) =>
            FadeTransition(opacity: a1, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // Deep gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
              ),
            ),
          ),

          // Animated green orb
          AnimatedBuilder(
            animation: _orbCtrl,
            builder: (ctx, snap) => Positioned(
              top: -80 + _orbCtrl.value * 30,
              right: -60,
              child: Container(
                width: size.width * 0.72,
                height: size.width * 0.72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.green.withValues(alpha: 0.35),
                      AppTheme.green.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Animated indigo orb
          AnimatedBuilder(
            animation: _orbCtrl,
            builder: (ctx, snap) => Positioned(
              bottom: -100 + (1 - _orbCtrl.value) * 40,
              left: -80,
              child: Container(
                width: size.width * 0.82,
                height: size.width * 0.82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.indigo.withValues(alpha: 0.3),
                      AppTheme.indigo.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Rotating rings
          Center(
            child: AnimatedBuilder(
              animation: _rotateCtrl,
              builder: (ctx, child) => Transform.rotate(
                angle: _rotateCtrl.value * 2 * math.pi,
                child: child,
              ),
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _rotateCtrl,
              builder: (ctx, child) => Transform.rotate(
                angle: -_rotateCtrl.value * 2 * math.pi * 0.7,
                child: child,
              ),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.035),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),

          // Floating dots
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (ctx, snap) => Positioned(
              top: size.height * 0.18,
              left: size.width * 0.14,
              child: Container(
                width: 6 + _pulseCtrl.value * 4,
                height: 6 + _pulseCtrl.value * 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.amber.withValues(
                    alpha: 0.65 - _pulseCtrl.value * 0.3,
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (ctx, snap) => Positioned(
              bottom: size.height * 0.22,
              right: size.width * 0.11,
              child: Container(
                width: 10 + (1 - _pulseCtrl.value) * 4,
                height: 10 + (1 - _pulseCtrl.value) * 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.green.withValues(
                    alpha: 0.5 - (1 - _pulseCtrl.value) * 0.2,
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (ctx, snap) => Positioned(
              top: size.height * 0.68,
              left: size.width * 0.08,
              child: Container(
                width: 5 + _pulseCtrl.value * 3,
                height: 5 + _pulseCtrl.value * 3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(
                    alpha: 0.3 - _pulseCtrl.value * 0.15,
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glass logo
                Center(
                  child: _GlassBox(
                    width: 112,
                    height: 112,
                    radius: 34,
                    child: const Center(
                      child: Text('🌱', style: TextStyle(fontSize: 58)),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.4, 0.4),
                        end: const Offset(1, 1),
                        duration: 900.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 500.ms),
                ),
                const SizedBox(height: 36),

                // Gradient title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF4ADE80), Color(0xFF818CF8)],
                  ).createShader(bounds),
                  child: Text(
                    'GrowWise',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.5,
                    ),
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 700.ms)
                    .slideY(begin: 0.4, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 10),

                Text(
                  'Giáo dục tài chính cho trẻ em',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.55),
                    letterSpacing: 0.3,
                  ),
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 80),

                _DotsLoader().animate(delay: 800.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsLoader extends StatefulWidget {
  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, snap) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final offset = i / 3;
          final t = (_ctrl.value + offset) % 1.0;
          final scale = math.sin(t * math.pi);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Transform.scale(
              scale: 0.4 + scale * 0.6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.3 + scale * 0.7),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _GlassBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Widget child;

  const _GlassBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppTheme.green.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}
