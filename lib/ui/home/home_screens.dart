import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/google_ads/custom_ad.dart';
import 'package:medinest/ui/appointment_screen/journal_screen_view.dart';
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
                              dividerColor:
                                  Get.theme.colorScheme.onBackground,
                              indicatorWeight: 0,
                              indicatorPadding:
                                  const EdgeInsets.symmetric(
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
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                        width: 2,
                                        color:
                                            Get.theme.colorScheme.primary,
                                      ),
                                    ),
                                    child: CommonText(
                                      text: 'txtMedicine'.tr,
                                      textColor:
                                          logic.selectedTabIndex == 0
                                              ? Get.theme.colorScheme
                                                  .background
                                              : Get.theme.colorScheme
                                                  .primary,
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
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                        width: 2,
                                        color:
                                            Get.theme.colorScheme.primary,
                                      ),
                                    ),
                                    child: CommonText(
                                      text: 'txtJournal'.tr,
                                      maxLines: 1,
                                      textColor:
                                          logic.selectedTabIndex == 1
                                              ? Get.theme.colorScheme
                                                  .background
                                              : Get.theme.colorScheme
                                                  .primary,
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
                          JournalScreenPage(),
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
                if (logic.selectedTabIndex == 0) {
                  logic.gotoAddMedicine(context);
                  return;
                }
                if (logic.selectedTabIndex == 1) {
                  logic.goToAddJournal(context);
                  return;
                }
              },
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Navigation Drawer
// ─────────────────────────────────────────────────────────────

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: Constant.idDrawerSheet,
      builder: (logic) {
        final genderIdx = Constant.genderList.indexOf(
          logic.userData?.gender ?? Constant.genderList[0],
        );
        final genderIcon =
            Constant.genderIconList[genderIdx < 0 ? 0 : genderIdx];

        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) => Scaffold.of(context).closeDrawer(),
          child: SafeArea(
            bottom: false,
            child: Drawer(
              width: AppSizes.fullWidth - 50,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.only(
                  topEnd: Radius.circular(28),
                  bottomEnd: Radius.circular(28),
                ),
              ),
              backgroundColor: Get.theme.colorScheme.background,
              child: Column(
                children: [
                  // ── Profile header ──────────────────────────────
                  _DrawerHeader(logic: logic, genderIcon: genderIcon),

                  // ── Nav items ────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      child: Column(
                        children: [
                          _DrawerItem(
                            icon: Assets.iconsIcHome,
                            label: 'txtHomepage'.tr,
                            onTap: () =>
                                Scaffold.of(context).closeDrawer(),
                          ),
                          _DrawerItem(
                            icon: Assets.iconsIcMedicine,
                            label: 'txtAddMedicine'.tr,
                            onTap: () {
                              _close(context);
                              logic.gotoAddMedicine(context);
                            },
                          ),
                          _DrawerItem(
                            icon: Assets.iconsIcFamilyMember,
                            label: 'txtAddFamilyMember'.tr,
                            onTap: () {
                              _close(context);
                              logic.gotoFamilyMember();
                            },
                          ),
                          _DrawerItem(
                            icon: Assets.iconsIcDoctor,
                            label: 'txtAddDoctor'.tr,
                            onTap: () {
                              _close(context);
                              logic.gotoDoctorScreen();
                            },
                          ),
                          _DrawerItem(
                            icon: Assets.iconsIcHistory,
                            label: 'txtHistory'.tr,
                            onTap: () {
                              _close(context);
                              logic.gotoHistoryScreen();
                            },
                          ),
                          _DrawerItem(
                            icon: Assets.iconsIcProfile,
                            label: 'txtProfile'.tr,
                            onTap: () => logic.goToProfile(context),
                          ),
                          _DrawerItem(
                            icon: Assets.iconsIcSetting,
                            label: 'txtSettings'.tr,
                            onTap: () {
                              _close(context);
                              logic.goToSetting(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Logout ───────────────────────────────────────
                  Divider(
                    height: 1,
                    color: Get.theme.colorScheme.surface
                        .withValues(alpha: 0.5),
                  ),
                  SafeArea(
                    top: false,
                    child: _LogoutRow(
                      onTap: () => logic.onTapSingOut(context),
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

  void _close(BuildContext context) =>
      Scaffold.of(context).closeDrawer();
}

// ─────────────────────────────────────────────────────────────
// Drawer header — avatar + name
// ─────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  final HomeController logic;
  final String genderIcon;

  const _DrawerHeader({required this.logic, required this.genderIcon});

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.07),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar with ring
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2.5),
            child: ClipOval(
              child: logic.userData?.profileImage != null
                  ? CachedNetworkImage(
                      imageUrl: logic.userData!.profileImage!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          _AvatarFallback(genderIcon: genderIcon),
                      errorWidget: (_, __, ___) =>
                          _AvatarFallback(genderIcon: genderIcon),
                    )
                  : _AvatarFallback(genderIcon: genderIcon),
            ),
          ),

          const SizedBox(width: 14),

          // Welcome + name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'txtWelcomeBack'.tr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.5),
                    fontFamily: Constant.fontFamilyLexendDeca,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  logic.userData?.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSecondary,
                    fontFamily: Constant.fontFamilyLexendDeca,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Single nav row
// ─────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final primary = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
          child: Row(
            children: [
              // Icon bubble
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                padding: const EdgeInsets.all(9),
                child: Image.asset(icon, color: primary),
              ),

              const SizedBox(width: 14),

              // Label
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onPrimary,
                    fontFamily: Constant.fontFamilyLexendDeca,
                  ),
                ),
              ),

              // Chevron
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Logout row
// ─────────────────────────────────────────────────────────────

class _LogoutRow extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFFF3B30);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                padding: const EdgeInsets.all(9),
                child: Image.asset(
                  Assets.iconsIcLogoutDrower,
                  color: red,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'txtLogOut'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: red,
                  fontFamily: Constant.fontFamilyLexendDeca,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Avatar fallback (gender icon on errorContainer bg)
// ─────────────────────────────────────────────────────────────

class _AvatarFallback extends StatelessWidget {
  final String genderIcon;

  const _AvatarFallback({required this.genderIcon});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Get.theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Image.asset(genderIcon, fit: BoxFit.contain),
      ),
    );
  }
}
