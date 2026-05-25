import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class ChildJars extends StatefulWidget {
  const ChildJars({super.key});

  @override
  State<ChildJars> createState() => _ChildJarsState();
}

class _ChildJarsState extends State<ChildJars>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ringAnim = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutCubic);
    Future.delayed(400.ms, () { if (mounted) _ringCtrl.forward(); });
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final total = app.totalCoins == 0 ? 1 : app.totalCoins;

    final jars = [
      _Jar('💰', 'Tiêu dùng', app.spendJar, total, const Color(0xFF3B82F6)),
      _Jar('🏦', 'Tiết kiệm', app.saveJar, total, AppTheme.green),
      _Jar('🤝', 'Sẻ chia', app.shareJar, total, AppTheme.coral),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hũ tiền',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Tổng cộng ${app.totalCoins} xu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppTheme.textHint,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Three rings
                    AnimatedBuilder(
                      animation: _ringAnim,
                      builder: (ctx, child) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: jars.map((j) => _Ring(
                          jar: j,
                          progress: _ringAnim.value,
                        )).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Allocation bar
                    _AllocationBar(jars: jars, total: total),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Chi tiết',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...jars.asMap().entries.map((e) =>
                    _JarCard(jar: e.value, progress: _ringAnim.value)
                        .animate(delay: Duration(milliseconds: e.key * 40))
                        .fadeIn(duration: 160.ms)
                        .slideY(begin: 0.05, end: 0),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Jar {
  final String icon;
  final String name;
  final int amount;
  final int total;
  final Color color;
  double get ratio => amount / total;
  String get pct => '${(ratio * 100).round()}%';

  const _Jar(this.icon, this.name, this.amount, this.total, this.color);
}

class _Ring extends StatelessWidget {
  final _Jar jar;
  final double progress;
  const _Ring({required this.jar, required this.progress});

  @override
  Widget build(BuildContext context) {
    final ringSize = (MediaQuery.of(context).size.width / 4.5).clamp(72.0, 100.0);
    return Column(
      children: [
        SizedBox(
          width: ringSize,
          height: ringSize,
          child: CustomPaint(
            painter: _RingPainter(
              progress: jar.ratio * progress,
              color: jar.color,
              bgColor: AppTheme.border,
              strokeWidth: 9,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(jar.icon, style: const TextStyle(fontSize: 22)),
                  Text(
                    jar.pct,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: jar.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${jar.amount} xu',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          jar.name,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppTheme.textHint,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;
  final double strokeWidth;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
    this.strokeWidth = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final bg = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bg);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        fg,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _AllocationBar extends StatelessWidget {
  final List<_Jar> jars;
  final int total;
  const _AllocationBar({required this.jars, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phân bổ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textHint,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: jars.map((j) => Flexible(
              flex: (j.ratio * 100).round().clamp(1, 100),
              child: Container(
                height: 12,
                color: j.color,
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: jars.map((j) => Expanded(
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(
                  color: j.color,
                  borderRadius: BorderRadius.circular(2),
                )),
                const SizedBox(width: 4),
                Text(j.name, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textHint)),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _JarCard extends StatelessWidget {
  final _Jar jar;
  final double progress;
  const _JarCard({required this.jar, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(jar.icon, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jar.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${jar.pct} tổng xu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${jar.amount}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: jar.color,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'xu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: jar.ratio * progress,
              minHeight: 6,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation(jar.color),
            ),
          ),
          if (jar.name == 'Tiêu dùng' && jar.amount > 0) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showTransfer(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: jar.color,
                  side: BorderSide(color: jar.color, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  'Chuyển sang hũ khác',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showTransfer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TransferSheet(spendJar: jar.amount),
    );
  }
}

class _TransferSheet extends StatefulWidget {
  final int spendJar;
  const _TransferSheet({required this.spendJar});

  @override
  State<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<_TransferSheet> {
  String _target = 'Tiết kiệm';
  int _amount = 10;

  @override
  Widget build(BuildContext context) {
    final quickAmounts = [5, 10, 20, 30];
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Chuyển xu',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hũ Tiêu dùng còn ${widget.spendJar} xu',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textHint),
          ),
          const SizedBox(height: 20),

          // Target selector
          Text(
            'Chuyển sang hũ',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Tiết kiệm', 'Sẻ chia'].map((name) {
              final active = _target == name;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _target = name),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: active ? AppTheme.green : AppTheme.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: active ? AppTheme.green : AppTheme.border,
                      ),
                    ),
                    child: Text(
                      name == 'Tiết kiệm' ? '🏦 $name' : '🤝 $name',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: active ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Amount
          Text(
            'Số lượng',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: quickAmounts.map((a) {
              final active = _amount == a;
              return GestureDetector(
                onTap: () => setState(() => _amount = a),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.green : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: active ? AppTheme.green : AppTheme.border),
                  ),
                  child: Text(
                    '$a xu',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: active ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                context.read<AppState>().transferToJar(_target, _amount);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Chuyển $_amount xu → $_target',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
