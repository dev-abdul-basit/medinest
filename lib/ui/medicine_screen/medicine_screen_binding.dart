import 'package:get/get.dart';

import 'medicine_screen_logic.dart';

class MedicineScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MedicineScreenLogic());
  }
}
