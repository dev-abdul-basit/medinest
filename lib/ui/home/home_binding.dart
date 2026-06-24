
import 'package:get/get.dart';
import 'package:medinest/ui/appointment_screen/journal_screen_logic.dart';
import 'package:medinest/ui/family_member_screen/family_member_screen_logic.dart';
import 'package:medinest/ui/home/home_controller.dart';
import 'package:medinest/ui/medicine_screen/medicine_screen_logic.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController(),permanent: true,);
    Get.put(MedicineScreenLogic(),permanent: true);
    Get.put(JournalScreenLogic(),permanent: true);
    /// F14 — Family is now a top-level tab inside HomeScreen, so its
    /// logic must be available before the tab body builds.
    Get.put(FamilyMemberScreenLogic(),permanent: true);
  }
}
