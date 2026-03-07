import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medinest/Widgets/appointmet_detail_dialog.dart';
import 'package:medinest/Widgets/common_delete_conformation.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/no_data_widget.dart';
import 'package:medinest/database/tables/journal_table.dart';
import 'package:medinest/database/tables/doctors_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/notification/notification_helper.dart';
import 'package:medinest/ui/appointment_screen/journal_screen_logic.dart';
import 'package:medinest/ui/home/home_controller.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/sizer_utils.dart';



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_delete_conformation.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/no_data_widget.dart';
import 'package:medinest/database/tables/journal_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/ui/appointment_screen/journal_screen_logic.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

class JournalListScreen extends StatelessWidget {
  final int familyMemberId;

  const JournalListScreen({
    super.key,
    required this.familyMemberId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<JournalScreenLogic>(
      id: Constant.idAppointmentList,
      builder: (logic) {
        /// FILTER JOURNALS FOR THIS FAMILY MEMBER
        final journals = logic.journalList
            .where((e) =>
        e!.bookedForFamilyMemberId == familyMemberId &&
            e.mIsDeleted != 1)
            .toList()
            .reversed
            .toList();

        if (journals.isEmpty) {
          return NoDataWidget(
            image: Assets.imagesImgNoMedicine,
            text: 'txtYouDontHaveAnyJournal'.tr,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            vertical: AppFontSize.size_10,
            horizontal: AppFontSize.size_4,
          ),
          itemCount: journals.length,
          itemBuilder: (context, index) {
            return journalItem(
              journalTable: journals[index]!,
            );
          },
        );
      },
    );
  }
}

/// ======================
/// JOURNAL ITEM UI
/// ======================
Widget journalItem({
  required JournalTable journalTable,
}) {
  return GetBuilder<JournalScreenLogic>(
    id: Constant.idAppointmentListItem,
    builder: (logic) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Get.theme.colorScheme.secondary.withOpacity(0.5),
              blurRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// CONTENT
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// JOURNAL TITLE
                  CommonText(
                    text: journalTable.mSoundTitle ?? '---',
                    fontSize: AppFontSize.size_16,
                    fontWeight: FontWeight.w600,
                    textColor: Get.theme.colorScheme.primary,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 8),

                  /// JOURNAL DESCRIPTION
                  CommonText(
                    text: journalTable.description ?? '',
                    fontSize: AppFontSize.size_14,
                    fontWeight: FontWeight.w400,
                    textColor: Get.theme.colorScheme.onSurface,
                    maxLines: 4,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            /// ACTION BUTTONS
            Row(
              children: [
                /// EDIT
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                      Get.theme.colorScheme.surfaceVariant,
                      foregroundColor:
                      Get.theme.colorScheme.primary,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.only(
                          bottomStart: Radius.circular(25),
                        ),
                      ),
                    ),
                    onPressed: () {
                      logic.gotoEditAppointment(journalTable);
                    },
                    child: Image.asset(
                      Assets.iconsIcEdit,
                      width: AppSizes.height_2,
                      height: AppSizes.height_2,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                ),

                /// DELETE
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Get.theme.colorScheme.primary,
                      foregroundColor:
                      Get.theme.colorScheme.background,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.only(
                          bottomEnd: Radius.circular(25),
                        ),
                      ),
                    ),
                    onPressed: () {
                      deleteBottomSheet(Get.context!, journalTable);
                    },
                    child: Image.asset(
                      Assets.iconsIcDeleteFill,
                      width: AppSizes.height_2,
                      height: AppSizes.height_2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

/// ======================
/// DELETE BOTTOM SHEET
/// ======================
Future<dynamic> deleteBottomSheet(
    BuildContext context,
    JournalTable journalTable,
    ) {
  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) => DeleteConformation(
      title: 'txtDeleteJournal'.tr,
      description: 'txtAreYouSureYouWantToDeleteThisJournal'.tr,
      onTapDelete: () {
        Get.find<JournalScreenLogic>()
            .deleteAppointment(journalTable);
      },
    ),
  );
}

