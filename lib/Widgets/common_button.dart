import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/utils/sizer_utils.dart';

/// Primary action button used app-wide.
///
/// Premium "liquid" treatment to match the glass bottom nav: a glossy primary
/// gradient (light → base → dark for a 3-D sheen), a soft coloured shadow for
/// lift, and a real ripple on every tap. Same size + API as before, so it is a
/// drop-in for every existing call site.
class CommonButton extends StatelessWidget {
  final void Function() onTap;
  final String text;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CommonButton({
    super.key,
    required this.onTap,
    required this.text,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Get.theme.colorScheme;
    final Color base = backgroundColor ?? scheme.primary;
    final BorderRadius radius = BorderRadius.circular(14);

    return Container(
      width: AppSizes.fullWidth - 50,
      height: AppSizes.height_7,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: backgroundColor,
        gradient: backgroundColor == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(base, Colors.white, 0.18)!,
                  base,
                  Color.lerp(base, Colors.black, 0.16)!,
                ],
                stops: const [0.0, 0.55, 1.0],
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: base.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          splashColor: Colors.white.withOpacity(0.22),
          highlightColor: Colors.white.withOpacity(0.08),
          onTap: onTap,
          child: Center(
            child: CommonText(
              text: text,
              textColor: foregroundColor ?? scheme.inversePrimary,
              textAlign: TextAlign.center,
              fontSize: AppFontSize.size_14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
