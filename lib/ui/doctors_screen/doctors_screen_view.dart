import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_appbar.dart';
import 'package:medinest/Widgets/common_button.dart';
import 'package:medinest/Widgets/common_listitem_person.dart';
import 'package:medinest/Widgets/no_data_widget.dart';
import 'package:medinest/Widgets/progress_dialog.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/google_ads/custom_ad.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';
import 'package:medinest/utils/utils.dart';
import 'package:scroll_to_hide/scroll_to_hide.dart';

import 'doctors_screen_logic.dart';

class DoctorsScreenPage extends StatelessWidget {
  const DoctorsScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<DoctorsScreenLogic>();

    return Stack(
      children: [
        GetBuilder<DoctorsScreenLogic>(
            id: Constant.idDoctorsList,
            builder: (logic) {
              return Scaffold(
                  backgroundColor: Get.theme.colorScheme.background,
                  appBar: CommonAppBar(title: 'txtDoctor'.tr),
                  body: logic.doctorsList.isNotEmpty
                      ? ListView.builder(
                          controller: logic.listController,
                    padding: EdgeInsets.only(
                        top: AppFontSize.size_12,
                        bottom: AppFontSize.size_50,
                        left: AppFontSize.size_8,right: AppFontSize.size_8),
                          itemCount: logic.doctorsList.reversed.toList().length,
                          itemBuilder: (context, index) {
                            return ItemPerson(
                              doctor: logic.doctorsList.reversed.toList()[index],
                            );
                          },
                        )
                      : NoDataWidget(
                          image: Utils.isLightTheme()
                              ? Assets.imagesImgNoFamilyMember
                              : Assets.imagesImgNoFamilyMemberDark,
                          text: 'txtYouDontHaveAnyDoctor'.tr,
                        ));
            }),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ScrollToHide(
              scrollController: logic.listController,
              height: AppSizes.height_15,
              duration: const Duration(milliseconds: 300),
              hideDirection: Axis.vertical,
              child: CommonButton(
                  onTap: logic.gotoAddDoctor, text: 'txtAddNewDoctor'.tr),
            ),
          ),
        ),
        const Align(alignment: Alignment.bottomCenter, child: BannerAdClass()),
        GetBuilder<DoctorsScreenLogic>(
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
