import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/premium_hero.dart';
import 'package:medinest/Widgets/progress_dialog.dart';
import 'package:medinest/in_app_purchase/in_app_purchase_helper.dart';
import 'package:medinest/ui/pro_version/pro_version_controller.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/utils.dart';

import '../../utils/sizer_utils.dart';

/// A single premium benefit shown on the paywall.
class _Benefit {
  final IconData icon;
  final String titleKey;
  final String subKey;
  const _Benefit(this.icon, this.titleKey, this.subKey);
}

/// MediNest Premium paywall.
///
/// A minimal, iOS-style purchase screen: a frameless top bar (close + restore),
/// a breathing hero, a clean benefit checklist, one highlighted plan card and a
/// single pinned gradient CTA. The brand emerald carries "premium / success";
/// navy is reserved for headings. No heavy boxed cards — whitespace does the
/// work.
class ProVersionScreen extends StatelessWidget {
  const ProVersionScreen({super.key});

  // Only real premium gates are advertised. "Unlimited appointments" was
  // removed — appointments are not part of the product.
  static const List<_Benefit> _benefits = [
    _Benefit(Icons.block_rounded, 'txtRemoveAds', 'txtPaywallFeatAdsSub'),
    _Benefit(Icons.medication_rounded, 'txtAddUnlimitedMedicines',
        'txtPaywallFeatMedsSub'),
    _Benefit(Icons.favorite_rounded, 'txtPaywallFeatSupportTitle',
        'txtPaywallFeatSupportSub'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Get.theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.background,
      body: SafeArea(
        child: GetBuilder<ProVersionController>(
          id: Constant.idProVersionProgress,
          builder: (logic) {
            return ProgressDialog(
              inAsyncCall: logic.isShowProgress,
              child: Column(
                children: [
                  _topBar(scheme, logic),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        AppSizes.width_6,
                        AppSizes.height_1,
                        AppSizes.width_6,
                        AppSizes.height_2,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(child: PremiumHero(size: AppSizes.height_16)),
                          SizedBox(height: AppSizes.height_2),
                          CommonText(
                            text: 'txtPaywallHeroTitle'.tr,
                            textColor: scheme.primary,
                            fontWeight: FontWeight.w800,
                            textAlign: TextAlign.center,
                            fontSize: AppFontSize.size_24,
                          ),
                          SizedBox(height: AppSizes.height_1),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.width_4),
                            child: CommonText(
                              text: 'txtPaywallHeroSub'.tr,
                              textColor: scheme.onSurface.withOpacity(0.55),
                              fontWeight: FontWeight.w400,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              fontSize: AppFontSize.size_13,
                            ),
                          ),
                          SizedBox(height: AppSizes.height_4),
                          ..._benefits.map((b) => _benefitRow(scheme, b)),
                          SizedBox(height: AppSizes.height_3),
                          _planCard(scheme),
                        ],
                      ),
                    ),
                  ),
                  _bottomBar(scheme, logic),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Frameless top bar — a close (X) and a quiet Restore action, the way a
  /// modal purchase sheet reads on iOS (no opaque title bar).
  Widget _topBar(ColorScheme scheme, ProVersionController logic) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.width_2,
        AppSizes.height_1,
        AppSizes.width_3,
        0,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.close_rounded,
                color: scheme.onSurface.withOpacity(0.7),
                size: AppSizes.height_3),
          ),
          const Spacer(),
          TextButton(
            onPressed: logic.onClickRestore,
            child: CommonText(
              text: 'txtRestore'.tr,
              textColor: scheme.secondary,
              fontWeight: FontWeight.w600,
              fontSize: AppFontSize.size_13,
            ),
          ),
        ],
      ),
    );
  }

  /// One benefit — an emerald icon chip + title + supporting line. Transparent
  /// (no boxed card) so the list reads light and premium.
  Widget _benefitRow(ColorScheme scheme, _Benefit b) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.height_2_5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: AppSizes.height_6,
            height: AppSizes.height_6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.secondary.withOpacity(0.12),
            ),
            child: Icon(b.icon,
                color: scheme.secondary, size: AppSizes.height_2_8),
          ),
          SizedBox(width: AppSizes.width_4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  text: b.titleKey.tr,
                  textColor: scheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: AppFontSize.size_15,
                ),
                SizedBox(height: AppSizes.height_0_3),
                CommonText(
                  text: b.subKey.tr,
                  textColor: scheme.onSurface.withOpacity(0.55),
                  fontWeight: FontWeight.w400,
                  maxLines: 2,
                  fontSize: AppFontSize.size_12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The highlighted plan — a selected, emerald-ringed card with a floating
  /// "Most popular" ribbon, the plan name on the left and the price on the
  /// right.
  Widget _planCard(ColorScheme scheme) {
    return GetBuilder<ProVersionController>(
      id: Constant.idAccessAllFeaturesButtons,
      builder: (logic) {
        final bool loaded = logic.products.isNotEmpty;
        final String price =
            loaded ? logic.products.last.price : 'txtProLoadingPrice'.tr;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.width_5,
                vertical: AppSizes.height_2_5,
              ),
              decoration: BoxDecoration(
                color: scheme.secondary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scheme.secondary, width: 1.6),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: scheme.secondary, size: AppSizes.height_3_5),
                  SizedBox(width: AppSizes.width_3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          text: 'txtMonthly'.tr,
                          textColor: scheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: AppFontSize.size_16,
                        ),
                        SizedBox(height: AppSizes.height_0_3),
                        CommonText(
                          text: 'txtPaywallCtaSubtext'.tr,
                          textColor: scheme.onSurface.withOpacity(0.55),
                          fontWeight: FontWeight.w400,
                          maxLines: 1,
                          fontSize: AppFontSize.size_11,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSizes.width_2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CommonText(
                        text: price,
                        textColor: scheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: AppFontSize.size_20,
                      ),
                      CommonText(
                        text: 'txtProPerMonth'.tr,
                        textColor: scheme.onSurface.withOpacity(0.55),
                        fontWeight: FontWeight.w500,
                        fontSize: AppFontSize.size_10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -AppSizes.height_1_3,
              left: AppSizes.width_5,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.width_3,
                  vertical: AppSizes.height_0_3,
                ),
                decoration: BoxDecoration(
                  color: scheme.secondary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: CommonText(
                  text: 'txtMostPopular'.tr.toUpperCase(),
                  textColor: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: AppFontSize.size_9,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Pinned CTA + trust line + legal links.
  Widget _bottomBar(ColorScheme scheme, ProVersionController logic) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.width_6,
        AppSizes.height_2,
        AppSizes.width_6,
        AppSizes.height_2,
      ),
      decoration: BoxDecoration(
        color: scheme.background,
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ctaButton(scheme, logic),
          SizedBox(height: AppSizes.height_1_5),
          CommonText(
            text: 'txtPaywallCtaSubtext'.tr,
            textColor: scheme.onSurface.withOpacity(0.55),
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
            fontSize: AppFontSize.size_11,
          ),
          SizedBox(height: AppSizes.height_1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legalLink('txtTerms&Conditions'.tr,
                  () => Utils.urlLauncher(Constant.termsAndConditionURL), scheme),
              CommonText(
                text: '   •   ',
                textColor: scheme.onSurface.withOpacity(0.35),
                fontWeight: FontWeight.w600,
                fontSize: AppFontSize.size_11,
              ),
              _legalLink('txtPrivacy'.tr,
                  () => Utils.urlLauncher(Constant.privacyPolicyURL), scheme),
            ],
          ),
        ],
      ),
    );
  }

  /// Premium emerald gradient CTA with a soft accent glow.
  Widget _ctaButton(ColorScheme scheme, ProVersionController logic) {
    final Color base = scheme.secondary;
    final String? price = InAppPurchaseHelper().monthlyPriceLabel;
    final String cta = 'txtPaywallCtaUpgrade'.tr;
    final String label = (price != null && price.trim().isNotEmpty)
        ? '$cta  ·  $price'
        : cta;
    final BorderRadius radius = BorderRadius.circular(16);

    return Container(
      width: double.infinity,
      height: AppSizes.height_7,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(base, Colors.white, 0.18)!,
            base,
            Color.lerp(base, Colors.black, 0.14)!,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: base.withOpacity(0.38),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          splashColor: Colors.white.withOpacity(0.22),
          highlightColor: Colors.white.withOpacity(0.08),
          onTap: logic.onPurchaseClick,
          child: Center(
            child: CommonText(
              text: label,
              textColor: Colors.white,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w700,
              fontSize: AppFontSize.size_15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _legalLink(String text, VoidCallback onTap, ColorScheme scheme) {
    return InkWell(
      onTap: onTap,
      child: CommonText(
        text: text,
        textColor: scheme.onSurface.withOpacity(0.5),
        fontWeight: FontWeight.w600,
        fontSize: AppFontSize.size_11,
      ),
    );
  }
}
