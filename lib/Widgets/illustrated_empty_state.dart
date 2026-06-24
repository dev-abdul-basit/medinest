import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/onboarding_illustrations.dart';
import 'package:medinest/utils/sizer_utils.dart';

/// Shared, engagement-focused empty state.
///
/// A custom (generated) illustration with a continuous **micro-animation**
/// (a gentle float + breathe), a motivating headline + subtitle, and a single
/// prominent call-to-action that drives the user straight into the screen's
/// primary action (add a reminder / note / family member). Empty screens are
/// the highest-intent moment to convert a new user — so they sell the action,
/// they don't just say "nothing here".
class IllustratedEmptyState extends StatefulWidget {
  final OnboardArt art;
  final String title;
  final String subtitle;

  /// The primary call-to-action (e.g. a [CommonButton]). Optional but expected
  /// on the core tabs.
  final Widget? action;

  const IllustratedEmptyState({
    super.key,
    required this.art,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  State<IllustratedEmptyState> createState() => _IllustratedEmptyStateState();
}

class _IllustratedEmptyStateState extends State<IllustratedEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Get.theme.colorScheme;
    final double artSize = AppSizes.fullWidth / 3.2;

    final Widget visual = AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        final double t = Curves.easeInOut.transform(_controller.value);
        final double scale = 0.96 + 0.08 * t;
        final double dy = -6.0 * math.sin(_controller.value * math.pi);
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: OnboardingIllustration(
        art: widget.art,
        size: artSize,
        color: scheme.primary,
      ),
    );

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.width_8,
          vertical: AppSizes.height_4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.width_6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withOpacity(0.07),
              ),
              child: visual,
            ),
            SizedBox(height: AppSizes.height_3),
            CommonText(
              text: widget.title,
              textAlign: TextAlign.center,
              textColor: scheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: AppFontSize.size_22,
            ),
            SizedBox(height: AppSizes.height_1),
            CommonText(
              text: widget.subtitle,
              textAlign: TextAlign.center,
              maxLines: 3,
              textColor: scheme.onSurface.withOpacity(0.55),
              fontWeight: FontWeight.w400,
              fontSize: AppFontSize.size_14,
            ),
            if (widget.action != null) ...[
              SizedBox(height: AppSizes.height_4),
              widget.action!,
            ],
          ],
        ),
      ),
    );
  }
}
