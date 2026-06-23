import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// GrowWise · Playful Modernism shared widgets.
/// These provide the signature tactile interactions that a plain ThemeData
/// cannot express (the 4px bottom-border "press-down" pill, candy-stripe
/// progress, the floating bubble nav).

enum GwButtonKind { primary, secondary, tertiary, ghost, danger }

/// Tall pill button with a 4px bottom border that compresses on press,
/// giving the tactile "button has depth" feel from the mockups.
class GwButton extends StatefulWidget {
  const GwButton({
    super.key,
    required this.label,
    this.onPressed,
    this.kind = GwButtonKind.primary,
    this.icon,
    this.expand = true,
    this.small = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final GwButtonKind kind;
  final IconData? icon;
  final bool expand;
  final bool small;

  @override
  State<GwButton> createState() => _GwButtonState();
}

class _GwButtonState extends State<GwButton> {
  bool _down = false;

  ({Color bg, Color fg, Color border}) _colors() {
    switch (widget.kind) {
      case GwButtonKind.primary:
        return (bg: AppTheme.vibrantPrimary, fg: AppTheme.onVibrantPrimary, border: const Color(0xFF904D00));
      case GwButtonKind.secondary:
        return (bg: AppTheme.secondaryContainer, fg: AppTheme.onSecondaryContainer, border: AppTheme.vibrantSecondary);
      case GwButtonKind.tertiary:
        return (bg: AppTheme.vibrantTertiary, fg: Colors.white, border: const Color(0xFF4600BB));
      case GwButtonKind.ghost:
        return (bg: Colors.white, fg: AppTheme.textPrimary, border: AppTheme.outlineVariant);
      case GwButtonKind.danger:
        return (bg: AppTheme.errorContainer, fg: AppTheme.onErrorContainer, border: const Color(0xFFBA1A1A));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors();
    final enabled = widget.onPressed != null;
    final restBorder = 4.0;
    final height = widget.small ? 42.0 : 52.0;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          width: widget.expand ? double.infinity : null,
          height: height,
          padding: EdgeInsets.symmetric(horizontal: widget.small ? 18 : 22),
          transform: Matrix4.translationValues(0, _down ? 3 : 0, 0),
          decoration: BoxDecoration(
            color: c.bg,
            borderRadius: BorderRadius.circular(999),
            border: Border(
              bottom: BorderSide(color: c.border, width: _down ? 1 : restBorder),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: widget.small ? 18 : 20, color: c.fg),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: c.fg,
                  fontSize: widget.small ? 14 : 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft rounded card with the warm shadow.
class GwCard extends StatelessWidget {
  const GwCard({super.key, required this.child, this.padding, this.glow = false, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool glow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        border: Border.all(color: const Color(0xFFF0E6D8), width: 1.5),
        boxShadow: glow
            ? [BoxShadow(color: AppTheme.vibrantPrimary.withValues(alpha: 0.30), blurRadius: 26, offset: const Offset(0, 12))]
            : AppTheme.cardShadow,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

/// Candy-stripe animated progress bar.
class GwProgress extends StatefulWidget {
  const GwProgress({super.key, required this.value, this.orange = false, this.height = 16});

  final double value; // 0..1
  final bool orange;
  final double height;

  @override
  State<GwProgress> createState() => _GwProgressState();
}

class _GwProgressState extends State<GwProgress> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fillColors = widget.orange
        ? const [Color(0xFFFBA53A), Color(0xFFFF8C00)]
        : const [Color(0xFF7EDB7B), Color(0xFF006E1C)];
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            Container(color: Colors.black.withValues(alpha: 0.07)),
            FractionallySizedBox(
              widthFactor: widget.value.clamp(0.0, 1.0),
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, _) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: fillColors),
                    backgroundBlendMode: BlendMode.srcOver,
                  ),
                  child: CustomPaint(
                    painter: _StripePainter(_c.value),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter(this.phase);
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.30);
    const step = 18.0;
    final offset = phase * step;
    for (double x = -size.height - step + offset; x < size.width + size.height; x += step) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + size.height, 0)
        ..lineTo(x + size.height + step / 2, 0)
        ..lineTo(x + step / 2, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.phase != phase;
}

/// Small rounded pill chip.
class GwChip extends StatelessWidget {
  const GwChip({super.key, required this.label, this.bg, this.fg, this.icon});

  final String label;
  final Color? bg;
  final Color? fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg ?? AppTheme.textSecondary), const SizedBox(width: 4)],
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: fg ?? AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
