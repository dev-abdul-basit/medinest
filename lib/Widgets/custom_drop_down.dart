import 'package:flutter/material.dart';
import 'package:medinest/Widgets/picker_bottom_sheet.dart';

/// A "dropdown" that opens a clean selection bottom sheet instead of a native
/// menu (better contrast + UX on the app's themed surfaces). Same public API as
/// before, so all call sites are unchanged.
class DropdownWithPrefix extends StatelessWidget {
  final Widget prefix;
  final Widget? suffix;
  final List<String> items;
  final String? selectedItem;
  final String hintText;
  final ValueChanged<String?> onChanged;

  const DropdownWithPrefix({
    super.key,
    required this.prefix,
    required this.items,
    this.selectedItem,
    required this.hintText,
    required this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return PickerField(
      prefix: prefix,
      hintText: hintText,
      valueText: selectedItem,
      onTap: () async {
        final String? result = await showSelectionSheet<String>(
          title: hintText,
          items: items,
          selected: selectedItem,
          labelOf: (s) => s,
        );
        if (result != null) onChanged(result);
      },
    );
  }
}
