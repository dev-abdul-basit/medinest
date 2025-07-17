import 'package:get/get.dart';

import 'add_or_edit_doctor_screen_logic.dart';

class AddOrEditDoctorScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddOrEditDoctorScreenLogic());
  }
}
