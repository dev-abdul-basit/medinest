import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_appbar.dart';
import 'package:medinest/Widgets/common_button.dart';
import 'package:medinest/Widgets/common_listitem_person.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/progress_dialog.dart';
import 'package:medinest/Widgets/self_profile_card.dart';
import 'package:medinest/google_ads/custom_ad.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:scroll_to_hide/scroll_to_hide.dart';

import 'family_member_screen_logic.dart';

/// Family members.
///
/// Used in two contexts:
///  - `embedded: true`  — as the Home "Family" tab. Home already provides the
///    app bar, the add FAB and the banner ad, so this renders **only** the list
///    or empty state (no duplicate chrome — that double-app-bar was the bug).
///  - `embedded: false` — as the standalone `/familyMember` route, with its own
///    app bar, add button and banner ad.
class FamilyMemberScreenPage extends StatelessWidget {
  final bool embedded;

  const FamilyMemberScreenPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<FamilyMemberScreenLogic>();

    final Widget content = GetBuilder<FamilyMemberScreenLogic>(
      id: Constant.idFamilyMemberList,
      builder: (logic) {
        // Dependents = everyone except the current user's own "Me" profile,
        // which is pinned at the top as the "You" card instead.
        final dependents = logic.familyMembersList
            .where((e) => e.mIsDeleted != 1 && e.fId != logic.selfMemberId)
            .toList()
            .reversed
            .toList();

        final Widget below = dependents.isEmpty
            ? _addMemberPrompt(logic)
            : ListView.builder(
                controller: logic.listController,
                padding: EdgeInsets.only(
                  top: AppSizes.height_1,
                  // Embedded: clear the floating glass nav + banner. Standalone:
                  // clear the floating add button.
                  bottom: embedded ? AppSizes.height_16 : AppSizes.height_12,
                  left: AppSizes.width_3,
                  right: AppSizes.width_3,
                ),
                itemCount: dependents.length,
                itemBuilder: (context, index) =>
                    ItemPerson(familyMember: dependents[index]),
              );

        return Column(
          children: [
            SizedBox(height: AppSizes.height_1),
            // The current user, always reachable & editable here.
            SelfProfileCard(
              self: logic.selfMember,
              onTapEdit: logic.gotoEditSelf,
            ),
            // Management header — always present so the section reads as a
            // labelled care roster, whether it has one person or several.
            _sectionHeader(dependents.length),
            Expanded(child: below),
          ],
        );
      },
    );

    final Widget progress = GetBuilder<FamilyMemberScreenLogic>(
      id: Constant.idProVersionProgress,
      builder: (l) =>
          ProgressDialog(inAsyncCall: l.isShowProgress, child: const SizedBox()),
    );

    if (embedded) {
      return Stack(children: [content, progress]);
    }

    // Standalone route — full chrome.
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Get.theme.colorScheme.background,
          appBar: CommonAppBar(title: 'txtFamilyMembers'.tr),
          body: content,
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ScrollToHide(
              scrollController: logic.listController,
              height: AppSizes.height_15,
              duration: const Duration(milliseconds: 300),
              hideDirection: Axis.vertical,
              child: CommonButton(
                onTap: logic.gotoAddMember,
                text: 'txtAddNewFamilyMember'.tr,
              ),
            ),
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: BannerAdClass(),
        ),
        progress,
      ],
    );
  }

  /// "Your family • N" management header — turns the section into a clear,
  /// labelled care roster. The count pill + "manage" subtitle only appear once
  /// there are dependents; with just the "You" card it stays a quiet title.
  Widget _sectionHeader(int count) {
    final scheme = Get.theme.colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.width_5,
        AppSizes.height_1_5,
        AppSizes.width_5,
        AppSizes.height_0_5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  text: 'txtYourFamily'.tr,
                  textColor: scheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: AppFontSize.size_16,
                ),
                if (count > 0) ...[
                  SizedBox(height: AppSizes.height_0_3),
                  CommonText(
                    text: 'txtManageFamilySub'.tr,
                    textColor: scheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w400,
                    maxLines: 2,
                    fontSize: AppFontSize.size_12,
                  ),
                ],
              ],
            ),
          ),
          if (count > 0) ...[
            SizedBox(width: AppSizes.width_2),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.width_3,
                vertical: AppSizes.height_0_5,
              ),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CommonText(
                text: '$count',
                textColor: scheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: AppFontSize.size_14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Shown when the only person is the user — a single, friendly "add a family
  /// member" card instead of the full-screen "Add your family" illustration
  /// (which felt redundant sitting under the "You" card).
  Widget _addMemberPrompt(FamilyMemberScreenLogic logic) {
    final scheme = Get.theme.colorScheme;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSizes.width_5,
        AppSizes.height_1,
        AppSizes.width_5,
        AppSizes.height_8,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: logic.gotoAddMember,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: AppSizes.height_4,
              horizontal: AppSizes.width_4,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.primary.withOpacity(0.35),
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSizes.width_4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primary.withOpacity(0.08),
                  ),
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: scheme.primary,
                    size: AppSizes.height_4,
                  ),
                ),
                SizedBox(height: AppSizes.height_2),
                CommonText(
                  text: 'txtAddNewFamilyMember'.tr,
                  textColor: scheme.primary,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.center,
                  fontSize: AppFontSize.size_16,
                ),
                SizedBox(height: AppSizes.height_0_5),
                CommonText(
                  text: 'txtNoFamilySub'.tr,
                  textColor: scheme.onSurface.withOpacity(0.55),
                  fontWeight: FontWeight.w400,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  fontSize: AppFontSize.size_13,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
