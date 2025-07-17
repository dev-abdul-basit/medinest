import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:medinest/Widgets/common_button_one.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/progress_dialog.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'full_screen_notification_logic.dart';

class FullScreenNotificationPage extends StatelessWidget {
  FullScreenNotificationPage({super.key});

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(Assets.imagesMedicineBackground),
              fit: BoxFit.cover),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor:
              Get.theme.colorScheme.onSurfaceVariant.withOpacity(0.90),
          body: GetBuilder<FullScreenNotificationLogic>(
              id: Constant.notificationAlert,
              builder: (logic) {
                DateTime time =
                    DateTime.parse(logic.notificationTable!.nNotificationTime!);

                return Center(
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          height: AppSizes.fullHeight / 1.33,
                          width: AppSizes.fullWidth - 70,
                          padding: EdgeInsets.only(
                              left: 14.0,
                              right: 14,
                              top: AppSizes.fullHeight / 5.5),
                          decoration: BoxDecoration(
                              color: Get.theme.colorScheme.tertiaryContainer,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Text('payload ${logic.payload ?? ''}'),
                              CommonText(
                                  text: DateFormat('hh:mm a').format(time),
                                  textColor:
                                      Get.theme.colorScheme.inverseSurface,
                                  fontWeight: FontWeight.w800,
                                  textAlign: TextAlign.center,
                                  fontSize: AppFontSize.size_35),

                              CommonText(
                                  text: '${logic.familyMemberTable?.name}',
                                  textColor:
                                      Get.theme.colorScheme.inverseSurface,
                                  fontWeight: FontWeight.w600,
                                  textAlign: TextAlign.center,
                                  fontSize: AppFontSize.size_14),

                              CommonText(
                                  text: 'txtItsTimeToTakeMedicine'.tr,
                                  textColor:
                                      Get.theme.colorScheme.inverseSurface,
                                  fontWeight: FontWeight.w400,
                                  textAlign: TextAlign.center,
                                  fontSize: AppFontSize.size_12),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  logic.imageData != null
                                      ? Image.memory(logic.imageData!,
                                          height: AppSizes.width_8,
                                          width: AppSizes.width_8)
                                      : const SizedBox(),
                                  SizedBox(width: AppSizes.height_1),
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth: AppSizes.fullWidth / 2),
                                    child: CommonText(
                                        text: logic.notificationTable?.nName ??
                                            '',
                                        maxLines: 2,
                                        textColor: Get
                                            .theme.colorScheme.inverseSurface,
                                        fontWeight: FontWeight.w600,
                                        fontSize: AppFontSize.size_18),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSizes.height_2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(Assets.iconsIcDosage,
                                      color: Colors.white,
                                      height: AppSizes.width_5,
                                      width: AppSizes.width_5),
                                  // logic.imageData != null
                                  //     ? Image.memory(logic.imageData!,
                                  //         color: Colors.white,
                                  //         height: AppSizes.width_5,
                                  //         width: AppSizes.width_5)
                                  //     : const SizedBox(),
                                  SizedBox(width: AppSizes.height_1),
                                  CommonText(
                                      text:
                                          '${logic.notificationTable?.nDosage} ${logic.notificationTable?.nUnits?.capitalizeFirst}',
                                      textColor:
                                          Get.theme.colorScheme.inverseSurface,
                                      fontWeight: FontWeight.w400,
                                      fontSize: AppFontSize.size_13),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: CommonButtonOne(
                                    onTap: logic.takeMedicine,
                                    backgroundColor:
                                        Get.theme.colorScheme.onSecondary,
                                    borderColor:
                                        Get.theme.colorScheme.onSecondary,
                                    textColor:
                                        Get.theme.colorScheme.inverseSurface,
                                    text: 'txtTaken'.tr),
                              ),
                              SizedBox(height: AppSizes.height_2),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: CommonButtonOne(
                                    onTap: () {
                                      logic.takeMedicine(true);
                                    },
                                    backgroundColor: Colors.transparent,
                                    borderColor:
                                        Get.theme.colorScheme.inverseSurface,
                                    textColor:
                                        Get.theme.colorScheme.inverseSurface,
                                    text: 'txtSkip'.tr),
                              ),
                              SizedBox(height: AppSizes.height_2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CommonText(
                                      text: 'txtSnoozeFor'.tr,
                                      textColor:
                                          Get.theme.colorScheme.inverseSurface,
                                      fontWeight: FontWeight.w400,
                                      textAlign: TextAlign.center,
                                      fontSize: AppFontSize.size_12),
                                  SizedBox(width: AppSizes.height_1),
                                  DropdownButton<int>(
                                    isExpanded: false,
                                    icon: Image.asset(Assets.iconsIcDropdown,
                                        color: Get
                                            .theme.colorScheme.inverseSurface,
                                        width: AppSizes.width_5,
                                        height: AppSizes.width_5),
                                    iconSize: 0,
                                    underline: Container(),
                                    hint: CommonText(
                                      text: '${logic.selectedMinute}min ',
                                      fontSize: AppFontSize.size_12,
                                      textColor:
                                          Get.theme.colorScheme.inverseSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    padding: EdgeInsets.zero,
                                    value: logic.selectedMinute,
                                    dropdownColor:
                                        Get.theme.colorScheme.onSurfaceVariant,
                                    // dropdownColor: Colors.red,
                                    items: Constant.snoozeMinutesList
                                        .map((item) => DropdownMenuItem(
                                              value: item,
                                              child: CommonText(
                                                text: '${item.toString()}Min',
                                                fontSize: AppFontSize.size_12,
                                                textColor: Get.theme.colorScheme
                                                    .inverseSurface,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: logic.onMinuteChange,
                                  )
                                ],
                              ),
                              SizedBox(height: AppSizes.height_2),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          left: 0,
                          right: 0,
                          top: 30,
                          child: Lottie.asset(Assets.animationAlarmClock,
                              width: AppSizes.height_28,
                              height: AppSizes.height_28)),
                      Positioned(
                        bottom: AppSizes.height_4,
                        left: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () async {
                            logic.stopRingTone();

                            await screenshotController
                                .capture()
                                .then((image) async {
                              if (image != null) {
                                final directory =
                                    await getApplicationDocumentsDirectory();
                                final imagePath =
                                    await File('${directory.path}/image.png')
                                        .create();
                                await imagePath.writeAsBytes(image).then(
                                    (value) async => await Share.shareXFiles(
                                        [XFile(imagePath.path)]));

                                /// Share Plugin
                              }
                            });
                          },
                          child: Image.asset(Assets.iconsIcShare,
                              height: AppSizes.width_11,
                              width: AppSizes.width_11),
                        ),
                      ),
                      ProgressDialog(
                        inAsyncCall: logic.isShowProgress,
                        child: const SizedBox(),
                      )
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  void shareImage(Uint8List image) async {
    final file = XFile.fromData(image);
    Share.shareXFiles([file]);
  }
}
