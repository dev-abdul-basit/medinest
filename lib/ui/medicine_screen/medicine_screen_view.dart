import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/member_avatar.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/ui/family_member_screen/family_member_screen_logic.dart';
import 'package:medinest/ui/medicine_screen/medicine_list_screen.dart';
import 'package:medinest/utils/constant.dart';

import 'medicine_screen_logic.dart';

class MedicineScreenPage extends StatelessWidget {
  const MedicineScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MedicineScreenLogic>(
      id: Constant.idMedicineScreenTab,
      builder: (logic) {
        final members = logic.familyMembersList
            .where((e) => e!.mIsDeleted != 1)
            .toList();

        return DefaultTabController(
          length: members.length,
          animationDuration: const Duration(milliseconds: 50),
          child: Column(
            children: [
              // ── Avatar chip tab row ──────────────────────────────────
              SizedBox(
                height: 86,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    return _AvatarChip(
                      member: members[index]!,
                      isSelected: logic.selectedTabIndex == index,
                      // Tap switches to this member; re-tapping the already
                      // selected member opens their profile.
                      onTap: () {
                        if (logic.selectedTabIndex == index) {
                          Get.find<FamilyMemberScreenLogic>()
                              .gotoEditMember(members[index]!);
                        } else {
                          logic.onTabSelected(index);
                        }
                      },
                    );
                  },
                ),
              ),

              // ── Content ──────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: logic.medicineTabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(
                    members.length,
                    (index) => MedicineListScreen(
                      familyMemberId: members[index]!.fId!,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Avatar chip
// ─────────────────────────────────────────────

class _AvatarChip extends StatelessWidget {
  final FamilyMemberTable member;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarChip({
    required this.member,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Get.theme.colorScheme.primary;
    final onSurface = Get.theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        margin: const EdgeInsets.only(right: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Avatar circle with selection ring ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primary : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              padding: const EdgeInsets.all(2.5),
              child: MemberAvatar(
                size: 45,
                profileImage: member.profileImage,
                gender: member.gender,
              ),
            ),

            const SizedBox(height: 5),

            // ── Name label ──
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? primary
                    : onSurface.withValues(alpha: 0.45),
                fontFamily: Constant.fontFamilyLexendDeca,
                leadingDistribution: TextLeadingDistribution.even,
              ),
              child: Text(
                member.name ?? '',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

