import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Onboarding / empty-state artwork.
///
/// Generated (not asset) vector illustrations drawn with [CustomPainter] —
/// copyright-free, crisp at any DPI, and theme-aware. They are **monochrome**:
/// a single hue rendered in opacity-layered shades, so they sit cleanly on the
/// app's blue panels (pass white) or on light cards (pass the primary blue)
/// without clashing accent colours. The palette stays in one blue family.
enum OnboardArt { pill, journal, family }

class OnboardingIllustration extends StatelessWidget {
  final OnboardArt art;
  final double size;

  /// Single hue for the whole glyph. Defaults to white (for the blue panels).
  final Color? color;

  const OnboardingIllustration({
    super.key,
    required this.art,
    this.size = 160,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _OnboardingPainter(
          art: art,
          color: color ?? Colors.white,
        ),
      ),
    );
  }
}

class _OnboardingPainter extends CustomPainter {
  final OnboardArt art;
  final Color color;

  _OnboardingPainter({required this.art, required this.color});

  Paint _fill(double opacity) => Paint()..color = color.withOpacity(opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double r = size.shortestSide / 2;
    canvas.drawCircle(center, r, _fill(0.12));
    canvas.drawCircle(center, r * 0.78, _fill(0.07));

    switch (art) {
      case OnboardArt.pill:
        _paintPill(canvas, size);
        break;
      case OnboardArt.journal:
        _paintJournal(canvas, size);
        break;
      case OnboardArt.family:
        _paintFamily(canvas, size);
        break;
    }
  }

  // ----- Pill (reminder) ----------------------------------------------------
  void _paintPill(Canvas canvas, Size size) {
    final double u = size.shortestSide;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi / 4);

    final Rect capsule = Rect.fromCenter(
      center: Offset.zero,
      width: u * 0.6,
      height: u * 0.3,
    );
    final RRect rcapsule =
        RRect.fromRectAndRadius(capsule, Radius.circular(u * 0.15));

    canvas.save();
    canvas.clipRRect(rcapsule);
    canvas.drawRect(
      Rect.fromLTRB(capsule.left, capsule.top, 0, capsule.bottom),
      _fill(1.0),
    );
    canvas.drawRect(
      Rect.fromLTRB(0, capsule.top, capsule.right, capsule.bottom),
      _fill(0.5),
    );
    canvas.restore();

    canvas.drawLine(
      Offset(0, capsule.top + u * 0.02),
      Offset(0, capsule.bottom - u * 0.02),
      Paint()
        ..color = color.withOpacity(0.6)
        ..strokeWidth = u * 0.012,
    );
    canvas.restore();

    // Sparkles — a few dots that read as "a dose, on time".
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.3), u * 0.045,
        _fill(0.85));
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.42), u * 0.028,
        _fill(0.6));
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.72), u * 0.032,
        _fill(0.55));
  }

  // ----- Journal (notes) ----------------------------------------------------
  // Mono line-art so the details read on top of the page (a filled page made
  // the details blend into a solid blue rectangle).
  void _paintJournal(Canvas canvas, Size size) {
    final double u = size.shortestSide;
    final Rect book = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: u * 0.5,
      height: u * 0.62,
    );
    final RRect rbook =
        RRect.fromRectAndRadius(book, Radius.circular(u * 0.06));

    // Faint page wash.
    canvas.drawRRect(rbook, _fill(0.14));
    // Crisp page outline.
    canvas.drawRRect(
      rbook,
      Paint()
        ..color = color.withOpacity(0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.022,
    );

    // Spine rule.
    final double spineX = book.left + u * 0.12;
    canvas.drawLine(
      Offset(spineX, book.top + u * 0.04),
      Offset(spineX, book.bottom - u * 0.04),
      Paint()
        ..color = color.withOpacity(0.55)
        ..strokeWidth = u * 0.018
        ..strokeCap = StrokeCap.round,
    );

    // Text lines.
    final double lx = spineX + u * 0.06;
    final Paint line = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = u * 0.024
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      final double ly = book.top + u * 0.16 + i * u * 0.12;
      final double lw = i.isEven ? u * 0.2 : u * 0.14;
      canvas.drawLine(Offset(lx, ly), Offset(lx + lw, ly), line);
    }

    // Heart accent — the "how you feel" cue.
    _drawHeart(
      canvas,
      Offset(book.right - u * 0.1, book.bottom - u * 0.12),
      u * 0.095,
      _fill(1.0),
    );
  }

  void _drawHeart(Canvas canvas, Offset c, double s, Paint paint) {
    final Path p = Path();
    p.moveTo(c.dx, c.dy + s * 0.3);
    p.cubicTo(
        c.dx - s, c.dy - s * 0.5, c.dx - s * 0.4, c.dy - s, c.dx, c.dy - s * 0.3);
    p.cubicTo(
        c.dx + s * 0.4, c.dy - s, c.dx + s, c.dy - s * 0.5, c.dx, c.dy + s * 0.3);
    canvas.drawPath(p, paint);
  }

  // ----- Family (multi-profile) --------------------------------------------
  void _paintFamily(Canvas canvas, Size size) {
    final double u = size.shortestSide;
    _avatar(canvas, Offset(size.width * 0.34, size.height * 0.52), u * 0.16,
        _fill(0.7));
    _avatar(canvas, Offset(size.width * 0.66, size.height * 0.52), u * 0.16,
        _fill(0.85));
    _avatar(canvas, Offset(size.width * 0.5, size.height * 0.56), u * 0.2,
        _fill(1.0));
  }

  void _avatar(Canvas canvas, Offset c, double s, Paint paint) {
    canvas.drawCircle(Offset(c.dx, c.dy - s * 0.55), s * 0.45, paint);
    final Rect body = Rect.fromCenter(
      center: Offset(c.dx, c.dy + s * 0.55),
      width: s * 1.5,
      height: s * 1.2,
    );
    canvas.drawArc(body, math.pi, math.pi, true, paint);
  }

  @override
  bool shouldRepaint(covariant _OnboardingPainter old) =>
      old.art != art || old.color != color;
}
