import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/google_ads/custom_ad.dart';
import 'package:medinest/ui/appointment_screen/appointment_screen_view.dart';
import 'package:medinest/ui/home/home_controller.dart';
import 'package:medinest/ui/medicine_screen/medicine_screen_view.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: Constant.idHome,
      builder: (logic) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            onDrawerChanged: logic.onDrawerChanged,
            key: _scaffoldKey,
            backgroundColor: Get.theme.colorScheme.onBackground,
            drawer: const NavigationDrawer(),
            body: PopScope(
              canPop: logic.canPop,
              onPopInvoked: logic.onWillPop,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 5,
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              _scaffoldKey.currentState!.openDrawer();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 6,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Get.theme.colorScheme.onTertiary,
                              ),
                              child: Image.asset(
                                Assets.iconsIcMenu,
                                color: Get.theme.colorScheme.surfaceVariant,
                                height: 18,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TabBar(
                              controller: logic.mainTabController,
                              onTap: logic.onTabSelected,
                              dividerColor: Get.theme.colorScheme.onBackground,
                              indicatorWeight: 0,
                              indicatorPadding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 5,
                              ),
                              indicator: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Get.theme.colorScheme.primary,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(100),
                                ),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelPadding: EdgeInsets.zero,
                              tabs: [
                                Tab(
                                  child: Container(
                                    width: AppSizes.fullWidth / 2.6,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        width: 2,
                                        color: Get.theme.colorScheme.primary,
                                      ),
                                    ),
                                    child: CommonText(
                                      text: 'txtMedicine'.tr,
                                      textColor: logic.selectedTabIndex == 0
                                          ? Get.theme.colorScheme.background
                                          : Get.theme.colorScheme.primary,
                                      textAlign: TextAlign.center,
                                      fontSize: AppFontSize.size_12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Container(
                                    width: AppSizes.fullWidth / 2.6,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        width: 2,
                                        color: Get.theme.colorScheme.primary,
                                      ),
                                    ),
                                    child: CommonText(
                                      text: 'txtJournal'.tr,
                                      maxLines: 1,
                                      textColor: logic.selectedTabIndex == 1
                                          ? Get.theme.colorScheme.background
                                          : Get.theme.colorScheme.primary,
                                      textAlign: TextAlign.center,
                                      fontSize: AppFontSize.size_12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: logic.mainTabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          MedicineScreenPage(),
                          AppointmentScreenPage(),
                        ],
                      ),
                    ),
                    const BannerAdClass(),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Get.theme.colorScheme.primary,
              child: Icon(
                logic.selectedTabIndex == 0 ? Icons.add : Icons.edit,
                color: Get.theme.colorScheme.background,
              ),
              onPressed: () {
                /// TAB 0 → MEDICINE
                if (logic.selectedTabIndex == 0) {
                  logic.gotoAddMedicine(context);
                  return;
                }

                /// TAB 1 → JOURNAL
                if (logic.selectedTabIndex == 1) {
                  logic.goToAddAppointment(context);
                  return;
                }
              },
            ),
          ),
        );
      },
    );
  }

  // @override
  // void onTopBarClick(EnumTopBar name, {bool value = true}) {
  //   if (name == EnumTopBar.topBarBack) {
  //     Get.back();
  //   }
  // }
}

drawerItem({
  Function()? onTap,
  String? text,
  String? icon,
  Widget? trailing,
  double? margin,
  double? vPadding,
  double? hPadding,
}) {
  return InkWell(
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: AppSizes.height_5_5,
          height: AppSizes.height_5_5,
          padding: const EdgeInsets.all(11),
          margin: EdgeInsets.symmetric(
            vertical: AppSizes.height_1_6,
            horizontal: AppSizes.width_3,
          ),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            color: Get.theme.colorScheme.primary,
          ),
          child: Image.asset(
            icon!,
            color: Get.context!.theme.colorScheme.inverseSurface,
          ),
        ),
        // Icon(icon, color: Get.context!.theme.primaryColor),
        Expanded(
          child: CommonText(
            text: text!,
            textColor: Get.theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: AppFontSize.size_12,
          ),
        ),
        if (trailing != null) ...{trailing},
      ],
    ),
  );
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: Constant.idDrawerSheet,
      builder: (logic) {
        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) => Scaffold.of(context).closeDrawer(),
          child: SafeArea(
            bottom: false,
            child: Drawer(
              width: AppSizes.fullWidth - 50,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.only(
                  topEnd: Radius.circular(40),
                ),
              ),
              backgroundColor: Get.theme.colorScheme.background,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: AppSizes.width_5,
                      top: 22.0,
                      bottom: 22.0,
                      end: AppSizes.width_6,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: AppSizes.height_8,
                          height: AppSizes.height_8,
                          // padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Get.theme.colorScheme.primary,
                          ),
                          child: logic.userData?.profileImage != null
                              ? CachedNetworkImage(
                                  imageUrl: logic.userData!.profileImage!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                  placeholder: (context, url) => Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Image.asset(
                                      Constant.genderIconList[Constant
                                          .genderList
                                          .indexOf(
                                            logic.userData?.gender ??
                                                Constant.genderList[0],
                                          )],
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Image.asset(
                                      Constant.genderIconList[Constant
                                          .genderList
                                          .indexOf(
                                            logic.userData?.gender ??
                                                Constant.genderList[0],
                                          )],
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Image.asset(
                                    Constant.genderIconList[Constant.genderList
                                        .indexOf(
                                          logic.userData?.gender ??
                                              Constant.genderList[0],
                                        )],
                                  ),
                                ),
                          // child: Image.asset(Constant.genderIconList[Constant.genderList.indexOf(logic.userData?.gender??Constant.genderList[0])]),

                          // Image.asset(logic.userData != null && logic.userData!.gender == Constant.genderList[0]
                          //     ? Assets.imagesImgUserMale
                          //     : Assets.iconsIcUserFemale)
                        ),
                        SizedBox(width: AppFontSize.size_10),
                        SizedBox(
                          height: AppSizes.height_8,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                text: 'txtWelcomeBack'.tr,
                                textColor: Get.theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w300,
                                fontSize: AppFontSize.size_10,
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: AppSizes.fullWidth / 2.1,
                                ),
                                child: CommonText(
                                  text: logic.userData != null
                                      ? logic.userData!.name!
                                      : '',
                                  maxLines: 1,
                                  textColor: Get.theme.colorScheme.onSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppFontSize.size_18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // const Spacer(),
                        /*Padding(
                            padding: const EdgeInsets.all(7),
                            child: InkWell(
                              onTap: () => Scaffold.of(context).closeDrawer(),
                              child: Image.asset(
                                Assets.iconsIcCloseDark,
                                color: Get.theme.colorScheme.tertiary,
                                height: AppSizes.height_1_7,
                                width: AppSizes.height_1_7,
                              ),
                            ),
                          ),*/
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: AppSizes.width_3,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            drawerItem(
                              onTap: () => Scaffold.of(context).closeDrawer(),
                              icon: Assets.iconsIcHome,
                              text: "txtHomepage".tr,
                            ),
                            drawerItem(
                              onTap: () {
                                closeDrawer(context);
                                logic.gotoAddMedicine(context);
                              },
                              icon: Assets.iconsIcMedicine,
                              text: "txtAddMedicine".tr,
                            ),
                            drawerItem(
                              onTap: () {
                                closeDrawer(context);
                                logic.gotoFamilyMember();
                              },
                              icon: Assets.iconsIcFamilyMember,
                              text: "txtAddFamilyMember".tr,
                            ),
                            drawerItem(
                              onTap: () {
                                closeDrawer(context);
                                logic.gotoDoctorScreen();
                              },
                              icon: Assets.iconsIcDoctor,
                              text: "txtAddDoctor".tr,
                            ),
                            drawerItem(
                              onTap: () {
                                closeDrawer(context);
                                logic.goToAddAppointment(context);
                              },
                              icon: Assets.iconsIcAppoinment,
                              text: "txtAddJournal".tr,
                            ),
                            drawerItem(
                              onTap: () {
                                closeDrawer(context);
                                logic.gotoHistoryScreen();
                              },
                              icon: Assets.iconsIcHistory,
                              text: "txtHistory".tr,
                            ),
                            drawerItem(
                              onTap: () => logic.goToProfile(context),
                              icon: Assets.iconsIcProfile,
                              text: "txtProfile".tr,
                            ),
                            drawerItem(
                              onTap: () {
                                closeDrawer(context);
                                logic.goToSetting(context);
                              },
                              icon: Assets.iconsIcSetting,
                              text: "txtSettings".tr,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Get.theme.colorScheme.surface.withOpacity(0.5),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: InkWell(
                      onTap: () {
                        logic.onTapSingOut(context);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            Assets.iconsIcLogoutDrower,
                            width: AppSizes.width_5,
                            height: AppSizes.width_5,
                            color: Get.theme.colorScheme.onSecondary,
                          ),
                          SizedBox(width: AppSizes.width_3),
                          CommonText(
                            text: 'txtLogOut'.tr,
                            textColor: Get.theme.colorScheme.onSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: AppFontSize.size_12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  closeDrawer(BuildContext context) {
    Scaffold.of(context).closeDrawer();
  }
}
