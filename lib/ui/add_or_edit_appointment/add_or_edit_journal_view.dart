import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_appbar.dart';
import 'package:medinest/Widgets/common_button_one.dart';
import 'package:medinest/Widgets/text_form_field.dart';
import 'package:medinest/Widgets/progress_dialog.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

import 'add_or_edit_journal_logic.dart';

class AddOrEditAppointmentPage extends StatelessWidget {
  AddOrEditAppointmentPage({super.key});

  final logic = Get.find<AddOrEditJournalLogic>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GetBuilder<AddOrEditJournalLogic>(
          id: Constant.addAppointment,
          builder: (logic) {
            return Scaffold(
              backgroundColor: Get.theme.colorScheme.background,
              appBar: CommonAppBar(
                title: logic.isEdit
                    ? 'txtUpdateJournal'.tr
                    : 'txtCreateJournal'.tr,
              ),
              body: SafeArea(top: false, child: SingleChildScrollView(
                child: Form(
                  key: logic.formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: AppSizes.height_3),
                        GetBuilder<AddOrEditJournalLogic>(
                          id: Constant.idAppointmentTitle,
                          builder: (logic) {
                            return CommonTextFormFieldWithSuffix(
                              controller: logic.titleController,
                              hintText: 'Enter Title'.tr,
                              fillColor: Get.theme.colorScheme.surfaceVariant,
                              keyboardType: TextInputType.text,
                              maxLines: 1,
                              prefixIcon: Assets.icons.icEdit.path,
                              validatorText: 'Enter Title'.tr,
                            );
                          },
                        ),
                        SizedBox(height: AppSizes.height_3),
                        GetBuilder<AddOrEditJournalLogic>(
                          id: Constant.idUserComment,
                          builder: (logic) {
                            return CommonTextFormFieldWithSuffix(
                              controller: logic.commentController,
                              hintText: 'txtEnterDescription'.tr,
                              fillColor: Get.theme.colorScheme.surfaceVariant,
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              prefixIcon: Assets.icons.icDescription.path,
                              validatorText: 'txtEnterDescription'.tr,
                            );
                          },
                        ),
                        SizedBox(height: AppSizes.height_5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CommonButtonOne(
                              onTap: () {
                                logic.clearData();
                              },
                              backgroundColor: Get.theme.colorScheme.background,
                              text: 'txtReset'.tr,
                            ),
                            SizedBox(width: AppSizes.height_2),
                            CommonButtonOne(
                              onTap: () async {
                                await logic.submitData(context);
                              },
                              text: logic.isEdit
                                  ? 'txtUpdateNow'.tr
                                  : 'txtSave'.tr,
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.height_2),
                      ],
                    ),
                  ),
                ),
              ),
              ),
            );
          },
        ),
        GetBuilder<AddOrEditJournalLogic>(
          id: Constant.idProVersionProgress,
          builder: (logic) {
            return ProgressDialog(
              inAsyncCall: logic.isShowProgress,
              child: const SizedBox(),
            );
          },
        ),
      ],
    );
  }
}
