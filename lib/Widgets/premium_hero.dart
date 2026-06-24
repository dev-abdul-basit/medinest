import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Premium paywall hero — a generated vector "gem".
///
/// Copyright-free, crisp at any DPI and theme-aware. The gem is filled with the
/// brand emerald gradient, faceted with light rim lines for a glassy sparkle,
/// and sits on a soft emerald glow.
class PremiumHero extends StatelessWidget {
  final double size;

  const PremiumHero({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Get.theme.colorScheme;
    final double gem = size * 0.62;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft accent glow behind the gem.
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  scheme.secondary.withOpacity(0.22),
                  scheme.secondary.withOpacity(0.0),
                ],
                stops: const [0.35, 1.0],
              ),
            ),
          ),
          CustomPaint(
            size: Size(gem, gem),
            painter: _GemPainter(
              top: scheme.secondary,
              bottom: Color.lerp(scheme.secondary, Colors.black, 0.28)!,
            ),
          ),
        ],
      ),
    );
  }
}

class _GemPainter extends CustomPainter {
  final Color top;
  final Color bottom;

  _GemPainter({required this.top, required this.bottom});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Diamond key points.
    final Offset tableL = Offset(w * 0.30, h * 0.26);
    final Offset tableR = Offset(w * 0.70, h * 0.26);
    final Offset girdleL = Offset(w * 0.12, h * 0.42);
    final Offset girdleR = Offset(w * 0.88, h * 0.42);
    final Offset tip = Offset(w * 0.50, h * 0.88);
    final Offset crownL = Offset(w * 0.42, h * 0.42);
    final Offset crownR = Offset(w * 0.58, h * 0.42);

    final Path outline = Path()
      ..moveTo(tableL.dx, tableL.dy)
      ..lineTo(tableR.dx, tableR.dy)
      ..lineTo(girdleR.dx, girdleR.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(girdleL.dx, girdleL.dy)
      ..close();

    // Brand gradient fill.
    final Paint fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, bottom],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(outline, fill);

    // Facet lines — thin light rims for the cut-glass sparkle.
    final Paint facet = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeJoin = StrokeJoin.round;

    canvas.drawLine(girdleL, girdleR, facet);
    canvas.drawLine(tableL, crownL, facet);
    canvas.drawLine(tableR, crownR, facet);
    canvas.drawLine(crownL, girdleL, facet);
    canvas.drawLine(crownR, girdleR, facet);
    canvas.drawLine(crownL, tip, facet);
    canvas.drawLine(crownR, tip, facet);
    canvas.drawLine(girdleL, tip, facet);
    canvas.drawLine(girdleR, tip, facet);

    // Bright table highlight.
    canvas.drawLine(
      tableL,
      tableR,
      Paint()
        ..color = Colors.white.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.018
        ..strokeCap = StrokeCap.round,
    );

    // Sparkles around the gem.
    _sparkle(canvas, Offset(w * 0.84, h * 0.16), w * 0.07);
    _sparkle(canvas, Offset(w * 0.14, h * 0.20), w * 0.045);
    _sparkle(canvas, Offset(w * 0.80, h * 0.70), w * 0.04);
  }

  /// A four-point twinkle.
  void _sparkle(Canvas canvas, Offset c, double s) {
    final Paint p = Paint()..color = Colors.white.withOpacity(0.9);
    final Path star = Path()
      ..moveTo(c.dx, c.dy - s)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + s, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + s)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - s, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - s)
      ..close();
    canvas.drawPath(star, p);
  }

  @override
  bool shouldRepaint(covariant _GemPainter old) =>
      old.top != top || old.bottom != bottom;
}
