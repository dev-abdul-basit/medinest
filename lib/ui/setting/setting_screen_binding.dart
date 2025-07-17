import 'package:get/get.dart';
import 'package:medinest/ui/setting/setting_screen_logic.dart';

class SettingScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingScreenLogic());
  }
}
