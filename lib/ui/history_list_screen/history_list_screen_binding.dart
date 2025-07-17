import 'package:get/get.dart';
import 'package:medinest/ui/appointment_history_screen/appointment_history_screen_logic.dart';
import 'package:medinest/ui/medicine_history_screen/medicine_history_screen_logic.dart';

import 'history_list_screen_logic.dart';

class HistoryListScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HistoryListScreenLogic());
    Get.put(MedicineHistoryScreenLogic());
    Get.put(AppointmentHistoryScreenLogic());
  }
}
