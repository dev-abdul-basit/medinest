import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:medinest/ui/add_medicine/add_medicine_binding.dart';
import 'package:medinest/ui/add_medicine/add_medicine_screens.dart';
import 'package:medinest/ui/add_or_edit_appointment/add_or_edit_appointment_binding.dart';
import 'package:medinest/ui/add_or_edit_appointment/add_or_edit_appointment_view.dart';
import 'package:medinest/ui/add_or_edit_doctor_screen/add_or_edit_doctor_screen_binding.dart';
import 'package:medinest/ui/add_or_edit_doctor_screen/add_or_edit_doctor_screen_view.dart';
import 'package:medinest/ui/add_or_edit_family_member_screen/add_or_edit_family_member_screen_binding.dart';
import 'package:medinest/ui/add_or_edit_family_member_screen/add_or_edit_family_member_screen_view.dart';
import 'package:medinest/ui/add_or_edit_profile_screen/add_or_edit_profile_screen_binding.dart';
import 'package:medinest/ui/add_or_edit_profile_screen/add_or_edit_profile_screen_view.dart';
import 'package:medinest/ui/change_language/change_language_binding.dart';
import 'package:medinest/ui/change_language/change_language_screen.dart';
import 'package:medinest/ui/doctors_screen/doctors_screen_binding.dart';
import 'package:medinest/ui/doctors_screen/doctors_screen_view.dart';
import 'package:medinest/ui/family_member_screen/family_member_screen_binding.dart';
import 'package:medinest/ui/family_member_screen/family_member_screen_view.dart';

import 'package:medinest/ui/full_screen_appointment_notification/full_screen_appointment_notification_binding.dart';
import 'package:medinest/ui/full_screen_appointment_notification/full_screen_appointment_notification_view.dart';
import 'package:medinest/ui/full_screen_notification/full_screen_notification_binding.dart';
import 'package:medinest/ui/full_screen_notification/full_screen_notification_view.dart';
import 'package:medinest/ui/get_started_screen/get_started_screen_binding.dart';
import 'package:medinest/ui/get_started_screen/get_started_screen_view.dart';
import 'package:medinest/ui/history_list_screen/history_list_screen_binding.dart';
import 'package:medinest/ui/history_list_screen/history_list_screen_view.dart';
import 'package:medinest/ui/home/home_binding.dart';
import 'package:medinest/ui/home/home_screens.dart';
import 'package:medinest/ui/introduction_screen/introduction_screen_binding.dart';
import 'package:medinest/ui/introduction_screen/introduction_screen_view.dart';
import 'package:medinest/ui/pro_version/pro_version_binding.dart';
import 'package:medinest/ui/pro_version/pro_version_screen.dart';
import 'package:medinest/ui/setting/setting_screen_binding.dart';
import 'package:medinest/ui/setting/setting_screen_view.dart';

import 'app_routes.dart';

class AppPages {
  static var list = [
    GetPage(
      name: AppRoutes.home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),

    GetPage(
      name: AppRoutes.add,
      page: () => AddMedicineScreen(),
      binding: AddMedicineBinding(),
    ),

    GetPage(
      name: AppRoutes.fullScreenNotification,
      page: () =>  FullScreenNotificationPage(),
      binding: FullScreenNotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.fullScreenAppointmentNotification,
      page: () =>  FullScreenAppointmentNotificationPage(),
      binding: FullScreenAppointmentNotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.historyScreen,
      page: () => const HistoryListScreenPage(),
      binding: HistoryListScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.proVersion,
      page: () => const ProVersionScreen(),
      binding: ProVersionBinding(),
    ),
    GetPage(
      name: AppRoutes.introduction,
      page: () => IntroductionScreenPage(),
      binding: IntroductionScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.getStarted,
      page: () => const GetStartedScreenPage(),
      binding: GetStartedScreenBinding(),
    ),

    GetPage(
      name: AppRoutes.addOrEditProfile,
      page: () => const AddOrEditProfileScreenPage(),
      binding: AddOrEditProfileScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.addOrEditFamilyMember,
      page: () => const AddOrEditFamilyMemberScreenPage(),
      binding: AddOrEditFamilyMemberScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.familyMember,
      page: () => const FamilyMemberScreenPage(),
      binding: FamilyMemberScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.doctorsScreen,
      page: () => const DoctorsScreenPage(),
      binding: DoctorsScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.addOrEditDoctor,
      page: () => const AddOrEditDoctorScreenPage(),
      binding: AddOrEditDoctorScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.addOrEditAppointment,
      page: () => AddOrEditAppointmentPage(),
      binding: AddOrEditAppointmentBinding(),
    ),
    GetPage(
      name: AppRoutes.setting,
      page: () => const SettingScreenPage(),
      binding: SettingScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.changeLanguage,
      page: () => ChangeLanguageScreen(),
      binding: ChangeLanguageBinding(),
    ),
  ];
}
