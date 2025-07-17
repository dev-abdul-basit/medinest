import 'package:get/get.dart';

import 'family_member_screen_logic.dart';

class FamilyMemberScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FamilyMemberScreenLogic());
  }
}
