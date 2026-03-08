import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_delete_conformation.dart';
import 'package:medinest/Widgets/no_data_widget.dart';
import 'package:medinest/database/tables/journal_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/ui/appointment_screen/journal_screen_logic.dart';
import 'package:medinest/utils/constant.dart';

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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: journals.length,
          itemBuilder: (context, index) {
            return _JournalCard(journalTable: journals[index]!);
          },
        );
      },
    );
  }
}

// ======================
// JOURNAL CARD
// ======================

class _JournalCard extends StatelessWidget {
  final JournalTable journalTable;

  const _JournalCard({required this.journalTable});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<JournalScreenLogic>(
      id: Constant.idAppointmentListItem,
      builder: (logic) {
        final theme = Get.theme;
        final primaryColor = theme.colorScheme.primary;
        final surfaceColor = theme.colorScheme.inversePrimary;
        final bodyColor = theme.colorScheme.onSurface;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => logic.gotoEditAppointment(journalTable),
                splashColor: primaryColor.withValues(alpha:0.06),
                highlightColor: primaryColor.withValues(alpha:0.03),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left accent bar
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                      ),

                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 16, 8, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon + Title
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha:0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.doc_text_fill,
                                      color: primaryColor,
                                      size: 17,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        journalTable.mSoundTitle ?? '---',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Description
                              if ((journalTable.description ?? '').isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  journalTable.description!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: bodyColor.withValues(alpha:0.65),
                                    height: 1.55,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Action buttons (vertical)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ActionButton(
                              icon: CupertinoIcons.pencil,
                              color: primaryColor,
                              onTap: () =>
                                  logic.gotoEditAppointment(journalTable),
                            ),
                            const SizedBox(height: 8),
                            _ActionButton(
                              icon: CupertinoIcons.trash,
                              color: const Color(0xFFFF3B30),
                              onTap: () =>
                                  deleteBottomSheet(Get.context!, journalTable),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ======================
// ACTION ICON BUTTON
// ======================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.09),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

// ======================
// DELETE BOTTOM SHEET
// ======================

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
        Get.find<JournalScreenLogic>().deleteAppointment(journalTable);
      },
    ),
  );
}
