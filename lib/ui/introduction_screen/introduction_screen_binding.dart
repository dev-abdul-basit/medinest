import 'package:get/get.dart';

import 'introduction_screen_logic.dart';

class IntroductionScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => IntroductionScreenLogic());
  }
}
