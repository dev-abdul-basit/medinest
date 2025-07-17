import 'package:get/get.dart';

import 'add_or_edit_appointment_logic.dart';

class AddOrEditAppointmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddOrEditAppointmentLogic());
  }
}
