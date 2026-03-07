
import 'package:get/get.dart';
import 'package:medinest/ui/appointment_screen/journal_screen_logic.dart';
import 'package:medinest/ui/home/home_controller.dart';
import 'package:medinest/ui/medicine_screen/medicine_screen_logic.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController(),permanent: true,);
    Get.put(MedicineScreenLogic(),permanent: true);
    Get.put(JournalScreenLogic(),permanent: true);
    // Get.lazyPut<HomeController>(
    //       () => HomeController(),
    // );
  }
}