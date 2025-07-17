import 'package:get/get.dart';

import 'medicine_history_screen_logic.dart';

class MedicineHistoryScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MedicineHistoryScreenLogic());
  }
}
