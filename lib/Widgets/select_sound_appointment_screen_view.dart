import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_button_one.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/ui/add_or_edit_appointment/add_or_edit_journal_logic.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

class SelectSoundAppointmentScreenPage extends StatelessWidget {
  const SelectSoundAppointmentScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.height_88,
      width: AppSizes.fullWidth,
      decoration: BoxDecoration(
          color: Get.theme.colorScheme.surfaceVariant,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(50))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonText(
                  text: "txtChooseSound".tr,
                  textAlign: TextAlign.center,
                  textColor: Get.theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSize.size_17),
              GetBuilder<AddOrEditJournalLogic>(
                  id: Constant.idSelectAlertSound,
                  builder: (logic) {
                    return InkWell(
                      onTap: () async {
                        // Debug.printLog("getLocale Updated");
                        logic.stopRingTone();
                        logic.getRingtones();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Get.context!.theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (logic.pickedTempRingtoneUri != null &&
                                  !logic.isRingPlaying)
                                InkWell(
                                    onTap: logic.playRingtone,
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Get.context!.theme.colorScheme
                                          .background,
                                    )),
                              if (logic.pickedTempRingtoneUri != null &&
                                  logic.isRingPlaying)
                                InkWell(
                                    onTap: logic.stopRingTone,
                                    child: Icon(
                                      Icons.pause,
                                      color: Get.context!.theme.colorScheme
                                          .background,
                                    )),
                              if (logic.pickedTempRingtoneUri == null &&
                                  !logic.isRingPlaying)
                                Image.asset(
                                  Assets.iconsIcFile,
                                  width: AppSizes.height_2,
                                ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                constraints: BoxConstraints(maxWidth: AppSizes.fullWidth-120),
                                child: CommonText(
                                    text: logic.pickedTempRingtoneTitle,
                                    maxLines: 1,
                                    textAlign: TextAlign.start,
                                    textColor: Get.theme.colorScheme.inverseSurface,
                                    fontWeight: FontWeight.w400,
                                    fontSize: AppFontSize.size_10),
                              )
                              // Text(logic.pickedRingtoneTitle),
                            ]),
                      ),
                    );
                  }),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: AppSizes.fullWidth / 3,
                    height: AppSizes.height_0_2,
                    color: Get.theme.colorScheme.surface,
                    margin: EdgeInsetsDirectional.fromSTEB(0,0,AppSizes.width_3,0),
                  ),
                  CommonText(
                      text: "txtOr".tr,
                      textAlign: TextAlign.center,
                      textColor: Get.theme.colorScheme.surface,
                      fontWeight: FontWeight.w600,
                      fontSize: AppFontSize.size_17),
                  Container(
                      height: AppSizes.height_0_2,
                      width: AppSizes.fullWidth / 3,
                      color: Get.theme.colorScheme.surface,
                      margin: EdgeInsetsDirectional.fromSTEB(AppSizes.width_3,0,0,0)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: buildSoundList(),
              ),
              SizedBox(
                height: AppFontSize.size_8_5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CommonButtonOne(
                      onTap: () {
                        Get.back();
                      },
                      backgroundColor: Get.theme.colorScheme.background,
                      text: 'txtCancel'.tr),
                  CommonButtonOne(onTap: (){
                    Get.find<AddOrEditJournalLogic>().saveSound();
                  }, text: 'txtSave'.tr),
                ],
              ),
              SizedBox(
                height: AppSizes.height_2,
              ),
            ],
          ),
        ),
      ),
    );
  }


  static Widget buildSoundList() {
    return GetBuilder<AddOrEditJournalLogic>(
        id: Constant.idListOfSounds,
        builder: (logic) {
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: Constant.soundList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return RadioListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: CommonText(
                    text: Constant.soundList[index],
                    textColor: Get.theme.colorScheme.primary,
                    fontWeight: FontWeight.w400,
                    fontSize: AppFontSize.size_13),
                value: Constant.soundList[index],
                selected: logic.pickedTempSoundTitle == Constant.soundList[index],
                groupValue: logic.pickedTempSoundTitle,
                controlAffinity: ListTileControlAffinity.trailing,
                fillColor: MaterialStateProperty.all<Color>(
                    logic.pickedTempSoundTitle == Constant.soundList[index]
                        ? Get.theme.colorScheme.onSecondary
                        : Get.theme.colorScheme.primaryContainer),
                onChanged: (value) {
                  logic.changeSelectedRing(sound: Constant.soundList[index]);
                  // Call a method or perform any action when a sound is selected
                  // For example: updateSelectedSound(soundList[index]);
                },
              );

              /*return CheckboxListTile(
                title: Text(Constant.soundList[index]),
                value: logic.selectedSoundList[index],
                onChanged: (value) {
                  logic.changeSelectedRing(index: index, value: value!);
                  // Call a method or perform any action when a sound is selected
                  // For example: updateSelectedSound(soundList[index]);
                },
              );*/
            },
          );
        });
  }
}
