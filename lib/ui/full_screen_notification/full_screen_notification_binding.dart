import 'package:get/get.dart';

import 'full_screen_notification_logic.dart';

class FullScreenNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FullScreenNotificationLogic());
  }
}
