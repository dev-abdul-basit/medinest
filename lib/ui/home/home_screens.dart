import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/today_plan_card.dart';
import 'package:medinest/Widgets/glass/liquid_glass_bottom_nav.dart';
import 'package:medinest/google_ads/custom_ad.dart';
import 'package:medinest/ui/appointment_screen/journal_screen_view.dart';
import 'package:medinest/ui/family_member_screen/family_member_screen_view.dart';
import 'package:medinest/ui/home/home_controller.dart';
import 'package:medinest/ui/medicine_screen/medicine_screen_view.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

/// F14 — Bottom-navigation refactor.
/// Drawer removed. Three top-level tabs: Reminders · Journal · Family.
/// Settings reached via gear icon in the app bar.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _tabReminders = 0;
  static const _tabJournal = 1;
  static const _tabFamily = 2;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: Constant.idHome,
      builder: (logic) {
        return Scaffold(
          backgroundColor: Get.theme.colorScheme.onBackground,
          // Let tab content scroll *behind* the floating glass nav so the frost
          // actually has something to refract. The banner ad sits above the nav
          // (opaque), and the lists carry bottom insets to clear both.
          extendBody: true,
          body: PopScope(
            canPop: logic.canPop,
            onPopInvoked: logic.onWillPop,
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Meaningful header: time-based greeting + per-tab line + gear.
                  _header(context, logic),
                  /// F08 — adherence card stays on top of the Reminders tab content.
                  if (logic.selectedTabIndex == _tabReminders)
                    GetBuilder<HomeController>(
                      id: Constant.idAdherenceCard,
                      builder: (l) {
                        final plan = l.todayPlan;
                        // Show the engagement summary once the user has at least
                        // one active medicine; the empty list state covers the
                        // no-medicines case.
                        if (plan == null || !plan.hasMedicines) {
                          return const SizedBox.shrink();
                        }
                        return TodayPlanCard(
                          plan: plan,
                          onTap: () => l.openAdherenceWeek(context),
                        );
                      },
                    ),
                  Expanded(
                    child: TabBarView(
                      controller: logic.mainTabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        MedicineScreenPage(),
                        JournalScreenPage(),
                        FamilyMemberScreenPage(embedded: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BannerAdClass(),
              LiquidGlassBottomNav(
                selectedIndex: logic.selectedTabIndex,
                onSelected: logic.onTabSelected,
                items: [
                  GlassNavItem(
                    icon: Icons.medication_outlined,
                    selectedIcon: Icons.medication,
                    label: 'txtMedicine'.tr,
                  ),
                  GlassNavItem(
                    icon: Icons.book_outlined,
                    selectedIcon: Icons.book,
                    label: 'txtJournal'.tr,
                  ),
                  GlassNavItem(
                    icon: Icons.people_outline,
                    selectedIcon: Icons.people,
                    label: 'txtFamily'.tr,
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Get.theme.colorScheme.primary,
            child: Icon(
              _fabIconFor(logic.selectedTabIndex),
              color: Get.theme.colorScheme.background,
            ),
            onPressed: () => _onFabTap(context, logic),
          ),
        );
      },
    );
  }

  /// Meaningful header — time-based greeting + a contextual line per tab and a
  /// settings gear (replaces the redundant static title; the bottom nav already
  /// names the tab).
  Widget _header(BuildContext context, HomeController logic) {
    final scheme = Get.theme.colorScheme;
    final double topInset = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.width_5,
        topInset + AppSizes.height_1_5,
        AppSizes.width_3,
        AppSizes.height_1,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  text: _greeting(),
                  textColor: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: AppFontSize.size_22,
                ),
                SizedBox(height: AppSizes.height_0_3),
                CommonText(
                  text: _taglineFor(logic.selectedTabIndex),
                  textColor: scheme.onSurface.withOpacity(0.55),
                  fontWeight: FontWeight.w400,
                  maxLines: 1,
                  fontSize: AppFontSize.size_13,
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => logic.goToSetting(context),
              child: Padding(
                padding: EdgeInsets.all(AppSizes.width_2_5),
                child: Icon(
                  Icons.settings_outlined,
                  color: scheme.primary,
                  size: AppFontSize.size_24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'txtGreetingMorning'.tr;
    if (hour < 17) return 'txtGreetingAfternoon'.tr;
    return 'txtGreetingEvening'.tr;
  }

  String _taglineFor(int tabIndex) {
    switch (tabIndex) {
      case _tabJournal:
        return 'txtJournalTagline'.tr;
      case _tabFamily:
        return 'txtFamilyTagline'.tr;
      case _tabReminders:
      default:
        return 'txtMedicineTagline'.tr;
    }
  }

  IconData _fabIconFor(int tabIndex) {
    switch (tabIndex) {
      case _tabJournal:
        return Icons.edit;
      case _tabFamily:
      case _tabReminders:
      default:
        return Icons.add;
    }
  }

  void _onFabTap(BuildContext context, HomeController logic) {
    switch (logic.selectedTabIndex) {
      case _tabReminders:
        logic.gotoAddMedicine(context);
        return;
      case _tabJournal:
        logic.goToAddJournal(context);
        return;
      case _tabFamily:
        logic.gotoAddFamilyMember(context);
        return;
    }
  }

}
