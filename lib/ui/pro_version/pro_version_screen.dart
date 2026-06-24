import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_appbar.dart';
import 'package:medinest/Widgets/common_button.dart';
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
      appBar: CommonAppBar(title: 'txtSubscription'.tr),
      body: SafeArea(
        top: false,
        child: GetBuilder<ProVersionController>(
          id: Constant.idProVersionProgress,
          builder: (logic) {
            return ProgressDialog(
              inAsyncCall: logic.isShowProgress,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.width_5,
                        vertical: AppSizes.height_2,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: PremiumHero(size: AppSizes.height_18),
                          ),
                          SizedBox(height: AppSizes.height_2),
                          Center(
                            child: CommonText(
                              text: 'txtPaywallHeroTitle'.tr,
                              textColor: scheme.primary,
                              fontWeight: FontWeight.w800,
                              textAlign: TextAlign.center,
                              fontSize: AppFontSize.size_22,
                            ),
                          ),
                          SizedBox(height: AppSizes.height_1),
                          Center(
                            child: CommonText(
                              text: 'txtPaywallHeroSub'.tr,
                              textColor: scheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w400,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              fontSize: AppFontSize.size_13,
                            ),
                          ),
                          SizedBox(height: AppSizes.height_3),
                          _planCard(scheme),
                          SizedBox(height: AppSizes.height_3),
                          CommonText(
                            text: 'txtPaywallFeaturesTitle'.tr.toUpperCase(),
                            textColor: scheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w700,
                            fontSize: AppFontSize.size_11,
                          ),
                          SizedBox(height: AppSizes.height_1_5),
                          ..._benefits.map((b) => Padding(
                                padding: EdgeInsets.only(
                                    bottom: AppSizes.height_1_5),
                                child: _benefitCard(scheme, b),
                              )),
                          SizedBox(height: AppSizes.height_2),
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

  /// The selected premium plan, on a primary-tinted glass surface with a
  /// "Most popular" ribbon.
  Widget _planCard(ColorScheme scheme) {
    return GetBuilder<ProVersionController>(
      id: Constant.idAccessAllFeaturesButtons,
      builder: (logic) {
        final String price = logic.products.isEmpty
            ? 'txtProLoadingPrice'.tr
            : logic.products.last.price;

        return Container(
          padding: EdgeInsets.all(AppSizes.width_5),
          decoration: BoxDecoration(
            color: scheme.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.secondary, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: scheme.secondaryContainer.withOpacity(0.2),
                spreadRadius: 0.5,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.width_4,
                  vertical: AppSizes.height_0_5,
                ),
                decoration: BoxDecoration(
                  color: scheme.secondary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded,
                        color: Colors.white, size: AppSizes.height_2),
                    SizedBox(width: AppSizes.width_1),
                    CommonText(
                      text: 'txtMostPopular'.tr.toUpperCase(),
                      textColor: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: AppFontSize.size_9,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.height_2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.workspace_premium_rounded,
                      color: scheme.primary, size: AppSizes.height_3),
                  SizedBox(width: AppSizes.width_2),
                  CommonText(
                    text: 'txtPremium'.tr,
                    textColor: scheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSize.size_16,
                  ),
                ],
              ),
              SizedBox(height: AppSizes.height_1),
              CommonText(
                text: price,
                textColor: scheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: AppFontSize.size_24,
              ),
              SizedBox(height: AppSizes.height_0_5),
              CommonText(
                text: 'txtProPerMonth'.tr,
                textColor: scheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                fontSize: AppFontSize.size_11,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _benefitCard(ColorScheme scheme, _Benefit b) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.width_4,
        vertical: AppSizes.height_2,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.height_6,
            height: AppSizes.height_6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.secondary.withOpacity(0.14),
            ),
            child: Icon(b.icon,
                color: scheme.secondary, size: AppSizes.height_3),
          ),
          SizedBox(width: AppSizes.width_3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  text: b.titleKey.tr,
                  textColor: scheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: AppFontSize.size_14,
                ),
                SizedBox(height: AppSizes.height_0_3),
                CommonText(
                  text: b.subKey.tr,
                  textColor: scheme.onSurface.withOpacity(0.6),
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

  /// Pinned CTA + trust line + legal links.
  Widget _bottomBar(ColorScheme scheme, ProVersionController logic) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.width_5,
        AppSizes.height_1_5,
        AppSizes.width_5,
        AppSizes.height_2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Builder(builder: (_) {
            final price = InAppPurchaseHelper().monthlyPriceLabel;
            final cta = 'txtPaywallCtaUpgrade'.tr.toUpperCase();
            final ctaText = (price != null && price.trim().isNotEmpty)
                ? '$cta — $price'
                : cta;
            return CommonButton(
              onTap: logic.onPurchaseClick,
              backgroundColor: scheme.primary,
              text: ctaText,
            );
          }),
          SizedBox(height: AppSizes.height_1_5),
          CommonText(
            text: 'txtPaywallCtaSubtext'.tr,
            textColor: scheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
            fontSize: AppFontSize.size_11,
          ),
          SizedBox(height: AppSizes.height_1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () =>
                    Utils.urlLauncher(Constant.termsAndConditionURL),
                child: CommonText(
                  text: 'txtTerms&Conditions'.tr,
                  textColor: scheme.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSize.size_11,
                ),
              ),
              CommonText(
                text: '   |   ',
                textColor: scheme.onSurface.withOpacity(0.4),
                fontWeight: FontWeight.w600,
                fontSize: AppFontSize.size_11,
              ),
              InkWell(
                onTap: () => Utils.urlLauncher(Constant.privacyPolicyURL),
                child: CommonText(
                  text: 'txtPrivacy'.tr,
                  textColor: scheme.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSize.size_11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
