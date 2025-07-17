import 'package:get/get.dart';
import 'package:medinest/utils/constant.dart';

class HistoryListScreenLogic extends GetxController {

  int selectedTabIndex=0;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
  void onTabSelected(int tabIndex) {
    selectedTabIndex = tabIndex;
    update([Constant.idHistoryList]);
  }

  void deleteSelectedHistory({int? hId}) {

  }
}
