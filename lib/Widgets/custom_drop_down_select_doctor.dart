import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/picker_bottom_sheet.dart';
import 'package:medinest/database/tables/doctors_table.dart';

/// Doctor selector — opens a selection bottom sheet instead of a native
/// dropdown. Same public API as before.
class DropdownWithPrefixSelectDoctor extends StatelessWidget {
  final Widget prefix;
  final Widget? suffix;
  final List<DoctorsTable> doctorsListItems;
  final DoctorsTable? selectedDoctorItem;
  final ValueChanged<DoctorsTable?> onChangedDoctor;

  const DropdownWithPrefixSelectDoctor({
    super.key,
    required this.prefix,
    required this.doctorsListItems,
    this.selectedDoctorItem,
    required this.onChangedDoctor,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final String title = 'txtSelectDoctor'.tr;
    return PickerField(
      prefix: prefix,
      hintText: title,
      valueText: selectedDoctorItem?.name,
      onTap: () async {
        final DoctorsTable? result = await showSelectionSheet<DoctorsTable>(
          title: title,
          items: doctorsListItems,
          selected: selectedDoctorItem,
          labelOf: (d) => d.name ?? '',
        );
        if (result != null) onChangedDoctor(result);
      },
    );
  }
}
