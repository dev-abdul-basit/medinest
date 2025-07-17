import 'package:get/get.dart';
import 'package:medinest/ui/sign_up/sign_up_logic.dart';


class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignUpLogic());
  }
}
