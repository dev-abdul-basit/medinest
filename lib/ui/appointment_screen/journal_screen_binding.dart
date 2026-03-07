import 'package:get/get.dart';

import 'journal_screen_logic.dart';

class JournalScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => JournalScreenLogic());
  }
}
