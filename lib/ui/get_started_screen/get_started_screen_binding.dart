import 'package:get/get.dart';

import 'get_started_screen_logic.dart';

class GetStartedScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetStartedScreenLogic());
  }
}
