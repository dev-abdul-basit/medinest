import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medinest/Widgets/common_appbar.dart';
import 'package:medinest/Widgets/common_button_one.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/custom_drop_down_select_doctor.dart';
import 'package:medinest/Widgets/custom_drop_down_select_member.dart';
import 'package:medinest/Widgets/dosage_bottom_sheet.dart';
import 'package:medinest/Widgets/picker_bottom_sheet.dart';
import 'package:medinest/Widgets/text_form_field.dart';
import 'package:medinest/Widgets/progress_dialog.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/ui/add_medicine/add_medicine_controller.dart';
import 'package:medinest/utils/asset.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/glass_tokens.dart';
import 'package:medinest/utils/sizer_utils.dart';

/// Add / Edit medicine — Apple-inspired, liquid-glass redesign.
///
/// Progressive disclosure: only Name + Dose + Time are required; the form opens
/// pre-filled with sensible defaults (handled in [AddMedicineController]).
/// Advanced, rarely-touched options (end date, sound, doctor, status) live under
/// a collapsible section so the core flow stays short. All controller logic and
/// `GetBuilder` ids are unchanged — this is a pure view rewrite.
class AddMedicineScreen extends StatelessWidget {
  final AddMedicineController addMedicineController =
      Get.find<AddMedicineController>();

  AddMedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = addMedicineController;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Get.theme.colorScheme.onBackground,
          appBar: CommonAppBar(
            title: logic.isEdit ? 'txtEditMedicine'.tr : 'txtAddMedicine'.tr,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.width_4,
                    AppSizes.height_2,
                    AppSizes.width_4,
                    AppSizes.height_3,
                  ),
                  child: Form(
                    key: logic.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _medicineSection(context, logic),
                        SizedBox(height: AppSizes.height_2_5),
                        _scheduleSection(context, logic),
                        SizedBox(height: AppSizes.height_2_5),
                        _whoSection(logic),
                        SizedBox(height: AppSizes.height_2_5),
                        _advancedSection(context, logic),
                        SizedBox(height: AppSizes.height_2),
                      ],
                    ),
                  ),
                ),
              ),
              _bottomBar(context, logic),
            ],
          ),
        ),
        GetBuilder<AddMedicineController>(
          id: Constant.idProVersionProgress,
          builder: (logic) => ProgressDialog(
            inAsyncCall: logic.isShowProgress,
            child: const SizedBox(),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────── Sections ─────────────────────────────

  Widget _medicineSection(BuildContext context, AddMedicineController logic) {
    return _section(
      title: 'txtMedicine'.tr,
      children: [
        GetBuilder<AddMedicineController>(
          id: Constant.idUserNameInput,
          builder: (logic) => CommonTextFormFieldWithSuffix(
            controller: logic.medicineNameController,
            hintText: '${'txtEnterMedicineName'.tr} *',
            maxLength: 30,
            fillColor: _fieldFill,
            prefixIcon: Assets.icons.icMedicineName.path,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp("[a-z A-Z 0-9]")),
            ],
            validatorText: 'txtEnterMedicineName'.tr,
          ),
        ),
        _gap,
        // Dosage = amount + unit, captured together in one guided sheet (clearer
        // than a bare "Add Dosage" number field).
        GetBuilder<AddMedicineController>(
          id: Constant.idSelectUnit,
          builder: (logic) {
            final String amount = logic.dosageController.text.trim();
            final String unit = (logic.dosageChoose ?? '').capitalizeFirst ?? '';
            return PickerField(
              prefix: Padding(
                padding: EdgeInsetsDirectional.only(start: AppSizes.width_3),
                child: Image.asset(
                  Assets.icons.icDosage.path,
                  width: AppSizes.width_5_5,
                  height: AppSizes.width_5_5,
                ),
              ),
              hintText: '${'txtSetDosage'.tr} *',
              valueText: amount.isEmpty ? null : '$amount $unit'.trim(),
              onTap: () async {
                final DosageResult? res = await showDosageSheet(
                  amount: logic.dosageController.text,
                  unit: logic.dosageChoose,
                  units: Constant.dosageDataList,
                );
                if (res != null) {
                  logic.dosageController.text = res.amount;
                  logic.dosageChoose = res.unit;
                  logic.update([Constant.idSelectUnit]);
                }
              },
            );
          },
        ),
        _gap,
        Row(
          children: [
            Expanded(
              child: GetBuilder<AddMedicineController>(
                id: Constant.idSelectedShape,
                builder: (logic) => _compactPicker(
                  icon: Assets.icons.icShape.path,
                  label: logic.selectedShape?.shapeName ?? 'txtSelectShape'.tr,
                  image: logic.selectedShape?.shapeImage,
                  onTap: () => logic.gotoSelectShape(context),
                ),
              ),
            ),
            SizedBox(width: AppSizes.width_3),
            Expanded(
              child: GetBuilder<AddMedicineController>(
                id: Constant.idSelectedColor,
                builder: (logic) => _compactPicker(
                  icon: Assets.icons.icColor.path,
                  label: 'txtChooseColor'.tr,
                  swatch: logic.shadeColor,
                  onTap: () => logic.gotoSelectColor(context),
                ),
              ),
            ),
          ],
        ),
        _gap,
        _label('txtSelectHowToTakeYourMedicine'.tr),
        SizedBox(height: AppSizes.height_1),
        GetBuilder<AddMedicineController>(
          id: Constant.idSelectBeforeOrAfterMeal,
          builder: (logic) => _mealSegmented(logic),
        ),
      ],
    );
  }

  Widget _scheduleSection(BuildContext context, AddMedicineController logic) {
    return _section(
      title: 'txtSetReminders'.tr,
      children: [
        Row(
          children: [
            Expanded(child: _label('${'txtSetTime'.tr} *')),
            GetBuilder<AddMedicineController>(
              id: Constant.idSelectedTime,
              builder: (logic) => _addPill(
                label: 'txtAddTime'.tr,
                onTap: () => logic.selectTime(context),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.height_1_5),
        buildSelectedTimeList(),
        _gap,
        GetBuilder<AddMedicineController>(
          id: Constant.idSelectFrequency,
          builder: (logic) => _rowPicker(
            icon: AppAsset.icFrequency,
            label: logic.frequency ?? 'txtSelectFrequency'.tr,
            onTap: logic.selectFrequency,
          ),
        ),
        _gap,
        GetBuilder<AddMedicineController>(
          id: Constant.idSelectStartDate,
          builder: (logic) => _rowPicker(
            icon: Assets.icons.icCalendar.path,
            label: 'txtStartDate'.tr,
            valueText: logic.startDate != null
                ? DateFormat('d MMM, yyyy').format(logic.startDate!)
                : 'txtSelectStartDate'.tr,
            onTap: logic.selectStartDate,
          ),
        ),
      ],
    );
  }

  Widget _whoSection(AddMedicineController logic) {
    return _section(
      title: 'txtAddMemberDoctor'.tr,
      children: [
        Row(
          children: [
            Expanded(
              child: GetBuilder<AddMedicineController>(
                id: Constant.idSelectMember,
                builder: (logic) => DropdownWithPrefixSelectMember(
                  prefix: Padding(
                    padding: EdgeInsetsDirectional.only(start: AppSizes.width_3),
                    child: Image.asset(
                      Assets.icons.icUserName.path,
                      width: AppSizes.width_5_5,
                      height: AppSizes.width_5_5,
                    ),
                  ),
                  hintText: '${'txtSelectMember'.tr} *',
                  familyMemberItems: logic.familyMembersList.reversed
                      .toList()
                      .where((element) => element.mIsDeleted != 1)
                      .toList(),
                  selectedFamilyMemberItem: logic.selectedFamilyMembers,
                  onChangedFamilyMember: (value) {
                    logic.selectedFamilyMembers = value!;
                    logic.update([Constant.idSelectMember]);
                  },
                ),
              ),
            ),
            SizedBox(width: AppSizes.width_2),
            _plusButton(onTap: logic.goToAddMember),
          ],
        ),
      ],
    );
  }

  Widget _advancedSection(BuildContext context, AddMedicineController logic) {
    return _glass(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: AppSizes.width_4),
          childrenPadding: EdgeInsets.fromLTRB(
            AppSizes.width_4,
            0,
            AppSizes.width_4,
            AppSizes.width_4,
          ),
          iconColor: Get.theme.colorScheme.primary,
          collapsedIconColor: Get.theme.colorScheme.primary,
          leading: Icon(
            Icons.tune_rounded,
            color: Get.theme.colorScheme.primary,
            size: AppFontSize.size_20,
          ),
          title: CommonText(
            text: 'txtAdvancedOptions'.tr,
            textColor: Get.theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: AppFontSize.size_15,
          ),
          children: [
            // End date + "no end date"
            GetBuilder<AddMedicineController>(
              id: Constant.idSelectEndDate,
              builder: (logic) => _rowPicker(
                icon: Assets.icons.icCalendar.path,
                label: 'txtEndDate'.tr,
                disabled: logic.isNoEndDate,
                valueText: logic.endDate != null && !logic.isNoEndDate
                    ? DateFormat('d MMM, yyyy').format(logic.endDate!)
                    : 'txtSelectEndDate'.tr,
                onTap: logic.isNoEndDate ? null : logic.selectEndDateDate,
              ),
            ),
            GetBuilder<AddMedicineController>(
              id: Constant.idNoEndDate,
              builder: (logic) => CheckboxListTile(
                title: CommonText(
                  text: 'txtNoEndDate'.tr,
                  textColor: Get.theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                  fontSize: AppFontSize.size_12,
                ),
                value: logic.isNoEndDate,
                activeColor: Get.theme.colorScheme.secondary,
                onChanged: (newValue) {
                  logic.isNoEndDate = newValue!;
                  logic.update([Constant.idNoEndDate, Constant.idSelectEndDate]);
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.trailing,
              ),
            ),
            if (Platform.isAndroid) ...[
              _gap,
              GetBuilder<AddMedicineController>(
                id: Constant.idSelectAlertSound,
                builder: (logic) => _rowPicker(
                  icon: Assets.icons.icSound.path,
                  label: logic.pickedSoundTitle ?? 'txtChooseSound'.tr,
                  onTap: logic.gotoSelectAlertSound,
                ),
              ),
            ],
            _gap,
            Row(
              children: [
                Expanded(
                  child: GetBuilder<AddMedicineController>(
                    id: Constant.idSelectDoctor,
                    builder: (logic) => DropdownWithPrefixSelectDoctor(
                      prefix: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: AppSizes.width_3,
                        ),
                        child: Image.asset(
                          Assets.icons.icDoctorName.path,
                          width: AppSizes.width_5_5,
                          height: AppSizes.width_5_5,
                        ),
                      ),
                      doctorsListItems: logic.doctorsList.reversed.toList(),
                      selectedDoctorItem: logic.selectedDoctorItem,
                      onChangedDoctor: (value) {
                        logic.selectedDoctorItem = value!;
                        logic.update([Constant.idSelectDoctor]);
                      },
                    ),
                  ),
                ),
                SizedBox(width: AppSizes.width_2),
                _plusButton(onTap: logic.goToAddDoctor),
              ],
            ),
            _gap,
            GetBuilder<AddMedicineController>(
              id: Constant.isUserActive,
              builder: (logic) => Row(
                children: [
                  CommonText(
                    text: 'txtStatus'.tr,
                    textColor: Get.theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: AppFontSize.size_13,
                  ),
                  SizedBox(width: AppSizes.width_2),
                  Expanded(
                    child: CommonText(
                      text: logic.isUserActive
                          ? 'txtActive'.tr
                          : 'txtSuspend'.tr,
                      textAlign: TextAlign.start,
                      textColor: logic.isUserActive
                          ? Get.theme.colorScheme.primary
                          : Get.theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: AppFontSize.size_13,
                    ),
                  ),
                  Switch.adaptive(
                    activeColor: Get.theme.colorScheme.secondary,
                    inactiveThumbColor: Get.theme.colorScheme.onSurface,
                    inactiveTrackColor:
                        Get.theme.colorScheme.onSurface.withOpacity(0.4),
                    value: logic.isUserActive,
                    onChanged: logic.onChangedActiveStatus,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────── Building blocks ─────────────────────────────

  Color get _fieldFill => Get.theme.colorScheme.surfaceVariant;
  Widget get _gap => SizedBox(height: AppSizes.height_2);

  /// A titled liquid-glass section card.
  Widget _section({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: AppSizes.width_2,
            bottom: AppSizes.height_1,
          ),
          child: CommonText(
            text: title,
            textColor: Get.theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: AppFontSize.size_15,
          ),
        ),
        _glass(
          padding: EdgeInsets.all(AppSizes.width_4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  /// Outlined section card — border only, no background shade/fill (per design
  /// request). The inner inputs keep their own subtle fills.
  Widget _glass({required Widget child, required EdgeInsetsGeometry padding}) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(GlassTokens.radiusLg),
        border: Border.all(
          color: Get.theme.colorScheme.primary.withOpacity(0.22),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _label(String text) {
    return CommonText(
      text: text,
      textColor: Get.theme.colorScheme.surface,
      fontWeight: FontWeight.w500,
      fontSize: AppFontSize.size_12,
    );
  }

  /// Full-width tappable picker row (frequency, dates, sound).
  Widget _rowPicker({
    required String icon,
    required String label,
    String? valueText,
    bool disabled = false,
    VoidCallback? onTap,
  }) {
    final scheme = Get.theme.colorScheme;
    final Color fg = disabled ? scheme.surface : scheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.width_3_5,
          horizontal: AppSizes.width_3,
        ),
        decoration: BoxDecoration(
          color: _fieldFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 1, color: scheme.surfaceTint),
        ),
        child: Row(
          children: [
            Image.asset(icon,
                width: AppSizes.width_5_5, height: AppSizes.width_5_5),
            SizedBox(width: AppSizes.width_3),
            Expanded(
              child: CommonText(
                text: label,
                textColor: disabled ? scheme.surface : scheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: AppFontSize.size_13,
              ),
            ),
            if (valueText != null)
              CommonText(
                text: valueText,
                textColor: fg,
                fontWeight: FontWeight.w600,
                fontSize: AppFontSize.size_12,
              ),
            SizedBox(width: AppSizes.width_1),
            Icon(Icons.chevron_right_rounded, color: fg, size: AppFontSize.size_22),
          ],
        ),
      ),
    );
  }

  /// Half-width compact picker (shape, colour).
  Widget _compactPicker({
    required String icon,
    required String label,
    Uint8List? image,
    Color? swatch,
    required VoidCallback onTap,
  }) {
    final scheme = Get.theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.width_3_5,
          horizontal: AppSizes.width_3,
        ),
        decoration: BoxDecoration(
          color: _fieldFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 1, color: scheme.surfaceTint),
        ),
        child: Row(
          children: [
            Image.asset(icon,
                width: AppSizes.width_5, height: AppSizes.width_5),
            SizedBox(width: AppSizes.width_2),
            Expanded(
              child: CommonText(
                text: label,
                maxLines: 1,
                textColor: scheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: AppFontSize.size_12,
              ),
            ),
            if (image != null)
              Image.memory(image,
                  width: AppSizes.width_6, height: AppSizes.width_6,
                  fit: BoxFit.cover),
            if (swatch != null)
              Container(
                width: AppSizes.width_6,
                height: AppSizes.width_6,
                decoration: BoxDecoration(
                  color: swatch,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: scheme.surfaceTint),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 3-way segmented meal selector (After / Before / Any).
  Widget _mealSegmented(AddMedicineController logic) {
    final scheme = Get.theme.colorScheme;
    final options = <Map<String, String>>[
      {'value': 'Take After A Meal', 'label': 'txtMealAfter'.tr},
      {'value': 'Take Before A Meal', 'label': 'txtMealBefore'.tr},
      {'value': 'Take Any Time', 'label': 'txtMealAny'.tr},
    ];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: scheme.surfaceTint),
      ),
      child: Row(
        children: options.map((o) {
          final bool selected = logic.beforeOrAfterMeal == o['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                logic.beforeOrAfterMeal = o['value'];
                logic.update([Constant.idSelectBeforeOrAfterMeal]);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: AppSizes.width_2_5),
                decoration: BoxDecoration(
                  color: selected ? scheme.secondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: CommonText(
                  text: o['label']!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  textColor: selected ? Colors.white : scheme.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: AppFontSize.size_12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _addPill({required String label, required VoidCallback onTap}) {
    final scheme = Get.theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.width_3,
          vertical: AppSizes.width_1_5,
        ),
        decoration: BoxDecoration(
          color: scheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded,
                color: scheme.primary, size: AppFontSize.size_18),
            SizedBox(width: AppSizes.width_1),
            CommonText(
              text: label,
              textColor: scheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: AppFontSize.size_12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _plusButton({required VoidCallback onTap}) {
    final scheme = Get.theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: AppSizes.height_6_5,
        width: AppSizes.height_6_5,
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.add_rounded,
            color: Colors.white, size: AppFontSize.size_24),
      ),
    );
  }

  Widget _bottomBar(BuildContext context, AddMedicineController logic) {
    final scheme = Get.theme.colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.width_4,
        AppSizes.height_1_5,
        AppSizes.width_4,
        AppSizes.height_1_5,
      ),
      decoration: BoxDecoration(
        color: scheme.onBackground,
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            CommonButtonOne(
              onTap: logic.clearData,
              backgroundColor: scheme.background,
              text: 'txtReset'.tr,
            ),
            SizedBox(width: AppSizes.width_3),
            Expanded(
              child: CommonButtonOne(
                onTap: () {
                  if (logic.isEdit) {
                    logic.updateMedicineToDatabase(Get.context);
                  } else {
                    logic.insertMedicineToDatabase(Get.context);
                  }
                },
                text: logic.isEdit ? 'txtUpdateNow'.tr : 'txtSave'.tr,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSelectedTimeList() {
    return GetBuilder<AddMedicineController>(
      id: Constant.idSelectedTime,
      builder: (logic) {
        if (logic.selectedTimeList.isEmpty) {
          return CommonText(
            text: 'txtNoTimesYet'.tr,
            textColor: Get.theme.colorScheme.surface,
            fontWeight: FontWeight.w400,
            fontSize: AppFontSize.size_11,
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(logic.selectedTimeList.length, (index) {
            final time = logic.selectedTimeList[index];
            return Container(
              padding: const EdgeInsets.fromLTRB(14, 7, 8, 7),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(
                    text: time.format(Get.context!),
                    textColor: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: AppFontSize.size_12,
                  ),
                  SizedBox(width: AppSizes.width_1),
                  GestureDetector(
                    onTap: () {
                      Debug.printLog(":: onDeleted :::");
                      logic.deleteTimeFormList(index);
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: AppFontSize.size_16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
