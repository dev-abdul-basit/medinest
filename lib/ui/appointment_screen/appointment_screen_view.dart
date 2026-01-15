import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/ui/appointment_screen/appointment_list_screen.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

import 'appointment_screen_logic.dart';

class AppointmentScreenPage extends StatelessWidget {
  const AppointmentScreenPage({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<AppointmentScreenLogic>(
        id: Constant.idAppointmentScreenTab,
        builder: (logic) {
          return DefaultTabController(
            length: logic.familyMembersList.where((element) => element!.mIsDeleted!=1).toList().length,
            animationDuration: const Duration(milliseconds: 50),
            child: Column(
              children: [
                // Align(
                //   alignment: AlignmentDirectional.centerStart,
                //   child: TabBar(
                //     controller: logic.appointmentTabController,
                //     onTap: logic.onTabSelected,
                //     isScrollable: true,
                //     tabAlignment: TabAlignment.start,
                //     dividerColor: Get.theme.colorScheme.background,
                //     indicatorColor: Colors.transparent,
                //     padding: EdgeInsets.symmetric(horizontal: AppSizes.width_2),
                //     labelPadding: EdgeInsets.symmetric(horizontal: AppSizes.width_1_5),
                //     tabs: List.generate(
                //       logic.familyMembersList.where((element) => element!.mIsDeleted!=1).toList().length,
                //       (index) => Tab(
                //         child: Container(
                //           alignment: Alignment.center,
                //           //TODO: ADD MEMBER NAME
                //           // child: CommonText(
                //           //     text: logic.familyMembersList.where((element) => element!.mIsDeleted!=1).toList()[index]!.name!,
                //           //     textColor: logic.selectedTabIndex == index
                //           //         ? Get.theme.colorScheme.onSecondary
                //           //         : Get.theme.colorScheme.onPrimary,
                //           //     textAlign: TextAlign.start,
                //           //     fontSize: AppFontSize.size_14,
                //           //     fontWeight: logic.selectedTabIndex == index
                //           //         ? FontWeight.w800
                //           //         : FontWeight.w300),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),


                Expanded(
                  child: TabBarView(
                    controller: logic.appointmentTabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                      logic.familyMembersList
                          .where((element) => element!.mIsDeleted != 1)
                          .toList()
                          .length,
                          (index) => AppointmentListScreen(
                        familyMemberId: logic.familyMembersList
                            .where((element) => element!.mIsDeleted != 1)
                            .toList()[index]!
                            .fId!,
                      ),
                    ),
                  ),
                ),


                // Expanded(
                //   child: TabBarView(
                //     controller: logic.appointmentTabController,
                //     physics: const NeverScrollableScrollPhysics(),
                //     children: List.generate(
                //       logic.familyMembersList.where((element) => element!.mIsDeleted!=1).toList().length,
                //       (index) => AppointmentListScreen(
                //           familyMemberId: logic.familyMembersList.where((element) => element!.mIsDeleted!=1).toList()[index]!.fId!),
                //     ),
                //   ),
                // ),
              ],
            ),
          );
        });
  }
}
