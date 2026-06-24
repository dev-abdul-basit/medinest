import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/utils/glass_tokens.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:medinest/utils/utils.dart';

/// One destination in the liquid-glass bottom navigation.
class GlassNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const GlassNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Glassmorphism bottom navigation — a floating, frosted pill that the content
/// scrolls behind (Home uses `extendBody: true`), with a glowing active pill
/// that glides between tabs and a ripple on every tap.
///
/// Recipe (per the liquid_glass_bar / glassmorphism-navbar references):
///  - rounded floating pill, soft drop shadow for separation over light screens
///  - BackdropFilter blur + saturation so content behind reads as frosted glass
///  - translucent tint (visible, not a slab) + a bright top sheen for the rim
///  - active item: a filled primary pill (with a soft glow) + white glyph,
///    inactive items muted; icon scales up on select.
///
/// Pure presentation: it owns no state. Parent passes `selectedIndex` +
/// `onSelected`, so it drops over the existing GetX tab flow unchanged.
class LiquidGlassBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<GlassNavItem> items;

  const LiquidGlassBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.items,
  });

  // Navbar-specific tints (kept here, derived from theme colours at use site —
  // opacities only, no hard-coded colours).
  static const double _fillTopLight = 0.62;
  static const double _fillBottomLight = 0.48;
  static const double _fillTopDark = 0.55;
  static const double _fillBottomDark = 0.40;
  static const double _barHeight = 66;
  static const double _radius = 30;

  @override
  Widget build(BuildContext context) {
    final bool light = Utils.isLightTheme();
    final ColorScheme scheme = Get.theme.colorScheme;
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    final Color fillBase = light ? Colors.white : scheme.surface;
    final BorderRadius radius = BorderRadius.circular(_radius);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.width_4,
        AppSizes.height_0_5,
        AppSizes.width_4,
        math.max(AppSizes.height_1_5, bottomInset),
      ),
      child: DecoratedBox(
        // Soft float shadow — separates the bar from light screens where the
        // glass alone wouldn't read.
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withOpacity(light ? 0.18 : 0.30),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.compose(
              outer: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              inner: ColorFilter.matrix(_saturationMatrix(1.4)),
            ),
            child: Container(
              height: _barHeight,
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    fillBase.withOpacity(light ? _fillTopLight : _fillTopDark),
                    fillBase
                        .withOpacity(light ? _fillBottomLight : _fillBottomDark),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(light ? 0.65 : 0.18),
                  width: 1.2,
                ),
              ),
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final int n = items.length;
                  final double itemWidth = constraints.maxWidth / n;
                  final double alignX =
                      n <= 1 ? 0 : (2 * selectedIndex / (n - 1)) - 1;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glowing active pill that glides under the selected tab.
                      // The aligned cell is a FULL tab width so the centering
                      // math is exact at every tab; the visible pill is inset
                      // within it (a narrower pill with edge-alignment would
                      // drift to the bar edges on the first/last tab).
                      AnimatedAlign(
                        duration: GlassTokens.motion,
                        curve: GlassTokens.motionCurve,
                        alignment: Alignment(alignX, 0),
                        child: SizedBox(
                          width: itemWidth,
                          height: _barHeight,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.width_2,
                              vertical: AppSizes.height_1,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius:
                                    BorderRadius.circular(GlassTokens.radiusMd),
                                boxShadow: [
                                  BoxShadow(
                                    color: scheme.primary.withOpacity(0.45),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(
                          n,
                          (i) => Expanded(child: _item(i, scheme)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(int index, ColorScheme scheme) {
    final GlassNavItem item = items[index];
    final bool selected = index == selectedIndex;
    final Color activeFg = Colors.white;
    final Color mutedFg = scheme.onSurface.withOpacity(0.55);
    final Color fg = selected ? activeFg : mutedFg;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(GlassTokens.radiusMd),
        splashColor: scheme.primary.withOpacity(0.16),
        highlightColor: scheme.primary.withOpacity(0.06),
        onTap: () => onSelected(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.12 : 1.0,
              duration: GlassTokens.motion,
              curve: GlassTokens.motionCurve,
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                color: fg,
                size: AppFontSize.size_22,
              ),
            ),
            SizedBox(height: AppSizes.height_0_5),
            CommonText(
              text: item.label,
              maxLines: 1,
              textAlign: TextAlign.center,
              textColor: fg,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              fontSize: AppFontSize.size_10,
            ),
          ],
        ),
      ),
    );
  }

  /// Rec. 709 saturation matrix so content behind stays vivid through the frost.
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
