import 'package:get/get.dart';

import 'add_or_edit_family_member_screen_logic.dart';

class AddOrEditFamilyMemberScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddOrEditFamilyMemberScreenLogic());
  }
}
