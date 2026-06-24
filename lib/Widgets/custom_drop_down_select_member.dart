import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/member_avatar.dart';
import 'package:medinest/Widgets/picker_bottom_sheet.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/utils/sizer_utils.dart';

/// Member selector — opens a selection bottom sheet (with avatars) instead of a
/// native dropdown. Same public API as before.
class DropdownWithPrefixSelectMember extends StatelessWidget {
  final Widget prefix;
  final Widget? suffix;
  final String? hintText;
  final List<FamilyMemberTable> familyMemberItems;
  final FamilyMemberTable? selectedFamilyMemberItem;
  final ValueChanged<FamilyMemberTable?> onChangedFamilyMember;

  const DropdownWithPrefixSelectMember({
    super.key,
    required this.prefix,
    required this.familyMemberItems,
    this.selectedFamilyMemberItem,
    required this.onChangedFamilyMember,
    this.suffix,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final String title = hintText ?? '${'txtBookingFor'.tr} *';
    return PickerField(
      prefix: prefix,
      hintText: title,
      valueText: selectedFamilyMemberItem?.name,
      onTap: () async {
        final FamilyMemberTable? result =
            await showSelectionSheet<FamilyMemberTable>(
          title: title,
          items: familyMemberItems,
          selected: selectedFamilyMemberItem,
          labelOf: (m) => m.name ?? '',
          leadingOf: (m) => SizedBox(
            width: AppSizes.height_4,
            height: AppSizes.height_4,
            child: MemberAvatar(
              size: AppSizes.height_4,
              profileImage: m.profileImage,
              gender: m.gender,
            ),
          ),
        );
        if (result != null) onChangedFamilyMember(result);
      },
    );
  }
}
