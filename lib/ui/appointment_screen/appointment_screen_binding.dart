import 'package:get/get.dart';

import 'appointment_screen_logic.dart';

class AppointmentScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppointmentScreenLogic());
  }
}
