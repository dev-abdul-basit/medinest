import 'package:get/get.dart';

import 'pro_version_controller.dart';

class ProVersionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProVersionController>(
      () => ProVersionController(),
    );
  }
}
