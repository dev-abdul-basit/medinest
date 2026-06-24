import 'package:flutter/material.dart';

/// Liquid-Glass design tokens.
///
/// Single source of truth for the "liquid glass" look so it stays consistent
/// app-wide and is tunable in one place — no magic numbers sprinkled in
/// widgets, no hard-coded colours (colours are always derived from the active
/// [ColorScheme] at the call site). Only dimensionless / opacity tokens live
/// here.
class GlassTokens {
  GlassTokens._();

  /// Backdrop blur strength (frost intensity). Kept in the 10–14 range — past
  /// ~18 it reads as muddy and costs more GPU (per Apple-style glass guidance).
  static const double blurSigma = 12.0;
  static const double blurSigmaStrong = 18.0;

  /// Saturation boost applied to the blurred backdrop (Rec. 709). This is what
  /// gives the "liquid glass" pop — colours behind the panel stay vivid through
  /// the frost instead of washing out. 1.0 = unchanged.
  static const double saturation = 1.7;

  /// Tint opacity over the blur. Frosted bars/cards need to stay clearly
  /// LEGIBLE — like an iOS tab bar, the glass is mostly opaque, not heavily
  /// see-through. Content behind reads as a faint frost, not a busy blur, so
  /// icons and labels keep strong contrast.
  static const double tintOpacityLight = 0.78;
  static const double tintOpacityDark = 0.62;

  /// Crisp glass rim. On light backgrounds a white edge is invisible, so the
  /// border is a primary-tinted hairline — clearly defined, still clean. The
  /// inner white sheen (below) keeps the glassy highlight.
  static const double borderOpacityLight = 0.30;
  static const double borderOpacityDark = 0.34;
  static const double borderWidth = 1.5;

  /// Top-edge sheen of the gradient.
  static const double sheenOpacityLight = 0.45;
  static const double sheenOpacityDark = 0.10;

  /// Selected-pill fill opacity (over the theme primary).
  static const double indicatorOpacity = 0.20;

  /// Soft elevation shadow under floating glass surfaces.
  static const double shadowOpacity = 0.12;
  static const double shadowBlur = 22.0;
  static const Offset shadowOffset = Offset(0, 8);

  /// Corner radii.
  static const double radiusSm = 14.0;
  static const double radiusMd = 20.0;
  static const double radiusLg = 28.0;
  static const double radiusPill = 100.0;

  /// Motion — the "liquid" slide/settle.
  static const Duration motion = Duration(milliseconds: 340);
  static const Curve motionCurve = Curves.easeOutCubic;
}
