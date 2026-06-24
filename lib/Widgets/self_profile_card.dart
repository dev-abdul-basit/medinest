import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/Widgets/member_avatar.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/generated/assets.dart';
import 'package:medinest/utils/sizer_utils.dart';

/// Pinned "You" card at the top of the Family tab.
///
/// Represents the current user's own profile (the implicit "Me"
/// [FamilyMemberTable] row that owns their own medicines). Visually distinct
/// from dependents — a primary-tinted border + a "You" badge — and taps through
/// to the same editor as Settings → Edit Profile, so the user manages
/// themselves in exactly one place.
class SelfProfileCard extends StatelessWidget {
  final FamilyMemberTable? self;
  final VoidCallback onTapEdit;

  const SelfProfileCard({
    super.key,
    required this.self,
    required this.onTapEdit,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Get.theme.colorScheme;
    final String name = (self?.name?.trim().isNotEmpty ?? false)
        ? self!.name!.trim()
        : 'txtSelfProfileName'.tr;

    final List<String> facts = [
      if ((self?.age ?? '').trim().isNotEmpty) self!.age!.trim(),
      if ((self?.bloodGroup ?? '').trim().isNotEmpty) self!.bloodGroup!.trim(),
    ];
    final String subtitle =
        facts.isNotEmpty ? facts.join('  •  ') : 'txtTapToCompleteProfile'.tr;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: AppSizes.height_1_5,
        horizontal: AppSizes.width_3,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        border: Border.all(color: scheme.primary, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.18),
            spreadRadius: 0.5,
            blurRadius: 8,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          splashColor: scheme.primary.withOpacity(0.12),
          highlightColor: scheme.primary.withOpacity(0.06),
          onTap: onTapEdit,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppSizes.height_2,
              horizontal: AppSizes.width_3,
            ),
            child: Row(
              children: [
                Container(
                  width: AppSizes.height_9,
                  height: AppSizes.height_9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.errorContainer,
                  ),
                  child: MemberAvatar(
                    size: AppSizes.height_9,
                    profileImage: self?.profileImage,
                    gender: self?.gender,
                  ),
                ),
                SizedBox(width: AppFontSize.size_10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: CommonText(
                              text: name,
                              textColor: scheme.primary,
                              fontWeight: FontWeight.w600,
                              maxLines: 1,
                              fontSize: AppFontSize.size_16,
                            ),
                          ),
                          SizedBox(width: AppFontSize.size_5),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.width_2,
                              vertical: AppSizes.height_0_5,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                            ),
                            child: CommonText(
                              text: 'txtYou'.tr,
                              textColor: scheme.onPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: AppFontSize.size_10,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.height_0_5),
                      CommonText(
                        text: subtitle,
                        textColor: scheme.onSurface,
                        fontWeight: FontWeight.w300,
                        maxLines: 1,
                        fontSize: AppFontSize.size_12,
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  Assets.icons.icEdit.path,
                  color: scheme.primary,
                  width: AppSizes.height_2_5,
                  height: AppSizes.height_2_5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
