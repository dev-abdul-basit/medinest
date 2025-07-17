import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_appbar.dart';
import 'package:medinest/localization/localizations_delegate.dart';
import 'package:medinest/ui/change_language/change_language_controller.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

class ChangeLanguageScreen extends StatelessWidget {
  ChangeLanguageScreen({super.key});

  final ChangeLanguageController _changeLanguageController = Get.find<ChangeLanguageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      appBar: CommonAppBar(
        title: 'txtChangeLanguages'.tr,
        actionWidget: Padding(
          padding: EdgeInsets.only(right: AppSizes.width_2, left: AppSizes.width_1_5),
          child: Icon(
            Icons.check_rounded,
            size: AppSizes.height_4,
            color: Get.theme.colorScheme.onPrimary,
          ),
        ),
        onActionTap: () {
          _changeLanguageController.onLanguageSave();
        },
      ),
      body: GetBuilder<ChangeLanguageController>(
        id: Constant.idChangeLanguage,
        builder: (logic) {
          return Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: AppSizes.height_2, horizontal: AppSizes.width_4),
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.width_2),
                  child: ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.only(top: AppSizes.height_2),
                    shrinkWrap: true,
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          logic.onChangeLanguage(languages[index]);
                        },
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Radio(
                                  value: languages[index],
                                  groupValue: logic.languagesChosenValue!,
                                  onChanged: (value) {
                                    logic.onChangeLanguage(value!);
                                  },
                                  fillColor: MaterialStateProperty.all<Color>(
                                      languages[index] == logic.languagesChosenValue!
                                          ? Get.theme.colorScheme.onSecondary
                                          : Get.theme.colorScheme.primaryContainer),
                                ),
                                Text(
                                  " ${languages[index].language}",
                                  style: TextStyle(
                                    color: languages[index] == logic.languagesChosenValue!
                                        ? Get.theme.colorScheme.onSecondary
                                        : Get.theme.colorScheme.primaryContainer,
                                    fontSize: AppFontSize.size_12_5,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  languages[index].symbol,
                                  style: TextStyle(
                                    color: languages[index] == logic.languagesChosenValue!
                                        ? Get.theme.colorScheme.onSecondary
                                        : Get.theme.colorScheme.primaryContainer,
                                    fontSize: AppFontSize.size_22,
                                  ),
                                ),
                                SizedBox(width: AppSizes.width_4),
                              ],
                            ),
                            _divider(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  _divider() {
    return Divider(
      color: Get.theme.colorScheme.surfaceTint.withOpacity(0.5),
      height: AppSizes.height_1,
    );
  }
}
