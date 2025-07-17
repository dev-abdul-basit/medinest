import 'package:get/get.dart';

import 'full_screen_appointment_notification_logic.dart';

class FullScreenAppointmentNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FullScreenAppointmentNotificationLogic());
  }
}
