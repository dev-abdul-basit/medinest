
import 'package:get/get.dart';
import 'package:medinest/ui/add_medicine/add_medicine_controller.dart';

class AddMedicineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddMedicineController>(
          () => AddMedicineController(),
    );
  }
}