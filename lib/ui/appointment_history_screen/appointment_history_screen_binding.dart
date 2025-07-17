import 'package:get/get.dart';

import 'appointment_history_screen_logic.dart';

class AppointmentHistoryScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppointmentHistoryScreenLogic());
  }
}
