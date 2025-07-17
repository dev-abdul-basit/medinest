import 'package:get/get.dart';

import 'add_or_edit_profile_screen_logic.dart';

class AddOrEditProfileScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddOrEditProfileScreenLogic());
  }
}
