import 'package:get/get.dart';

import 'doctors_screen_logic.dart';

class DoctorsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorsScreenLogic());
  }
}
