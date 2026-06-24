import 'package:get/get.dart';

import 'first_medicine_logic.dart';

class FirstMedicineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FirstMedicineLogic());
  }
}
