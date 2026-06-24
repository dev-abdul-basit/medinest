import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/utils/glass_tokens.dart';
import 'package:medinest/utils/utils.dart';

/// Reusable "liquid glass" surface: a frosted, translucent panel with a blurred
/// backdrop, a soft edge highlight and an optional sheen + shadow.
///
/// Theme-aware by construction — the tint, border and sheen are all derived
/// from the active [ColorScheme], so the same widget reads correctly in light
/// and dark mode. This is the single primitive every glass surface in the app
/// should be built from (bottom nav, app bar, cards, dialogs) to keep the look
/// consistent and maintainable.
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry? padding;

  /// Optional tint override; defaults to a theme surface tone.
  final Color? tint;

  /// Soft drop shadow for floating surfaces (bars, cards). Off for inline fills.
  final bool elevated;

  /// Top-edge gradient sheen — the classic glass highlight.
  final bool sheen;

  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = GlassTokens.radiusLg,
    this.blur = GlassTokens.blurSigma,
    this.padding,
    this.tint,
    this.elevated = true,
    this.sheen = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool light = Utils.isLightTheme();
    final ColorScheme scheme = Get.theme.colorScheme;

    // Tint base: theme background tone (white-ish in light, dark surface in
    // dark) so the frost matches the app surface in either mode.
    final Color base = tint ?? scheme.background;
    final double tintOpacity =
        light ? GlassTokens.tintOpacityLight : GlassTokens.tintOpacityDark;
    final double borderOpacity =
        light ? GlassTokens.borderOpacityLight : GlassTokens.borderOpacityDark;
    final double sheenOpacity =
        light ? GlassTokens.sheenOpacityLight : GlassTokens.sheenOpacityDark;
    // A white rim disappears on a light background, so use a primary-tinted
    // hairline in light mode for a clearly-defined glass edge; white in dark.
    final Color edge = light ? scheme.primary : Colors.white;

    final BorderRadius radius = BorderRadius.circular(borderRadius);

    // Frost = blur + saturation boost on the backdrop. The saturation is what
    // keeps colours behind the panel vivid through the blur — the "liquid
    // glass" pop that a plain BackdropFilter lacks. (ColorFilter implements
    // ImageFilter, so it composes with the blur.)
    final ImageFilter frost = ImageFilter.compose(
      outer: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      inner: ColorFilter.matrix(_saturationMatrix(GlassTokens.saturation)),
    );

    // RepaintBoundary so the (expensive) backdrop blur is not re-rasterised
    // when unrelated parts of the screen repaint.
    Widget glass = RepaintBoundary(
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: frost,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: base.withOpacity(tintOpacity),
              borderRadius: radius,
              border: Border.all(
                color: edge.withOpacity(borderOpacity),
                width: GlassTokens.borderWidth,
              ),
              // Diagonal specular sheen — bright at the top-left, a faint
              // secondary glint bottom-right — reads as a curved glass lens.
              gradient: sheen
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(sheenOpacity),
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(sheenOpacity * 0.35),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (!elevated) return glass;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(GlassTokens.shadowOpacity),
            blurRadius: GlassTokens.shadowBlur,
            offset: GlassTokens.shadowOffset,
          ),
        ],
      ),
      child: glass,
    );
  }

  /// Rec. 709 luminance-preserving saturation matrix. [s] = 1 is identity.
  static List<double> _saturationMatrix(double s) {
    const double lr = 0.2126, lg = 0.7152, lb = 0.0722;
    final double ir = (1 - s) * lr, ig = (1 - s) * lg, ib = (1 - s) * lb;
    return <double>[
      ir + s, ig, ib, 0, 0,
      ir, ig + s, ib, 0, 0,
      ir, ig, ib + s, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }
}
