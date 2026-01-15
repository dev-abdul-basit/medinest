import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/google_ads/custom_ad.dart';
import 'package:medinest/ui/appointment_history_screen/appointment_history_screen_view.dart';
import 'package:medinest/ui/medicine_history_screen/medicine_history_screen_view.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

import '../../Widgets/common_appbar.dart';
import 'history_list_screen_logic.dart';

class HistoryListScreenPage extends StatelessWidget {
  const HistoryListScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'History'.tr),
      backgroundColor: Get.theme.colorScheme.onPrimaryContainer,
      body: GetBuilder<HistoryListScreenLogic>(
        id: Constant.idHistoryList,
        builder: (logic) {
          return SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(child: MedicineHistoryScreenPage()),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: BannerAdClass(),
                  ),
                ],
              ),
            ),
            // child: DefaultTabController(
            //   length: 1,
            //   child: Column(
            //     children: [
            //       Container(
            //         width: AppSizes.fullWidth,
            //         padding: const EdgeInsets.only(
            //           top: 10,
            //           left: 14.0,
            //           right: 14.0,
            //         ),
            //         // margin: Platform.isIOS ? EdgeInsets.zero : const EdgeInsets.only(top: 30),
            //         decoration: BoxDecoration(
            //           color: Get.theme.colorScheme.onPrimaryContainer,
            //         ),
            //         child: TabBar(
            //           onTap: logic.onTabSelected,
            //           dividerColor: Colors.transparent,
            //           indicatorWeight: 0,
            //           indicatorPadding: EdgeInsets.symmetric(
            //             horizontal: AppSizes.width_2_5,
            //           ),
            //           indicator: BoxDecoration(
            //             shape: BoxShape.rectangle,
            //             color: Get.theme.colorScheme.secondaryContainer,
            //             borderRadius: const BorderRadius.all(
            //               Radius.circular(100),
            //             ),
            //           ),
            //           indicatorSize: TabBarIndicatorSize.tab,
            //           labelPadding: EdgeInsets.zero,
            //           tabs: [
            //             Tab(
            //               child: Container(
            //                 alignment: Alignment.center,
            //                 margin: EdgeInsetsDirectional.symmetric(
            //                   horizontal: AppSizes.width_2_5,
            //                 ),
            //                 decoration: BoxDecoration(
            //                   borderRadius: BorderRadius.circular(100),
            //                   border: Border.all(
            //                     width: 2,
            //                     color: Get.theme.colorScheme.secondaryContainer,
            //                   ),
            //                 ),
            //                 child: CommonText(
            //                   text: 'txtMedicine'.tr,
            //                   textColor: logic.selectedTabIndex == 0
            //                       ? Get.theme.colorScheme.inverseSurface
            //                       : Get.theme.colorScheme.secondaryContainer,
            //                   textAlign: TextAlign.center,
            //                   fontSize: AppFontSize.size_12,
            //                   fontWeight: FontWeight.w700,
            //                 ),
            //               ),
            //             ),
            //             // Tab(
            //             //   child: Container(
            //             //     alignment: Alignment.center,
            //             //     margin: EdgeInsetsDirectional.symmetric(
            //             //       horizontal: AppSizes.width_2_5,
            //             //     ),
            //             //     decoration: BoxDecoration(
            //             //       borderRadius: BorderRadius.circular(100),
            //             //       border: Border.all(
            //             //         width: 2,
            //             //         color: Get.theme.colorScheme.secondaryContainer,
            //             //       ),
            //             //     ),
            //             //     child: CommonText(
            //             //       text: 'txtAppointment'.tr,
            //             //       maxLines: 1,
            //             //       textColor: logic.selectedTabIndex == 1
            //             //           ? Get.theme.colorScheme.inverseSurface
            //             //           : Get.theme.colorScheme.secondaryContainer,
            //             //       textAlign: TextAlign.center,
            //             //       fontSize: AppFontSize.size_12,
            //             //       fontWeight: FontWeight.w700,
            //             //     ),
            //             //   ),
            //             // ),
            //           ],
            //         ),
            //       ),
            //       const Expanded(
            //         child: TabBarView(
            //           physics: NeverScrollableScrollPhysics(),
            //           children: [
            //             MedicineHistoryScreenPage(),
            //             //AppointmentHistoryScreenPage(),
            //           ],
            //         ),
            //       ),
            //       const Align(
            //         alignment: Alignment.bottomCenter,
            //         child: BannerAdClass(),
            //       ),
            //     ],
            //   ),
            // ),
          );
        },
      ),
    );
  }
}
