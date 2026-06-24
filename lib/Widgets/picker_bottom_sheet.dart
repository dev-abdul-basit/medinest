import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

/// Reusable selection bottom sheet — the app-wide replacement for native
/// `DropdownButton` menus (which rendered with poor contrast on the themed
/// surfaces). Theme-correct in light & dark: a clean rounded sheet with a drag
/// handle, title, and a tappable list where the current selection is marked with
/// the secondary (accent) colour.
///
/// Returns the chosen item, or null if dismissed.
Future<T?> showSelectionSheet<T>({
  required String title,
  required List<T> items,
  T? selected,
  required String Function(T) labelOf,
  Widget Function(T)? leadingOf,
}) {
  final ColorScheme scheme = Get.theme.colorScheme;

  return Get.bottomSheet<T>(
    Container(
      constraints: BoxConstraints(maxHeight: AppSizes.fullHeight * 0.7),
      decoration: BoxDecoration(
        color: scheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle.
          Container(
            margin: EdgeInsets.only(top: AppSizes.height_1_5),
            width: AppSizes.width_12,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.surface.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSizes.width_5,
              AppSizes.height_2,
              AppSizes.width_5,
              AppSizes.height_1,
            ),
            child: Row(
              children: [
                Expanded(
                  child: CommonText(
                    text: title,
                    textColor: scheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSize.size_16,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close_rounded,
                      color: scheme.onSurface, size: AppFontSize.size_22),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: scheme.surface.withOpacity(0.2)),
          Flexible(
            child: items.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(AppSizes.height_3),
                    child: CommonText(
                      text: 'txtNoData'.tr,
                      textColor: scheme.surface,
                      fontWeight: FontWeight.w400,
                      fontSize: AppFontSize.size_13,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: AppSizes.height_1),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final T item = items[i];
                      final bool isSel =
                          selected != null && labelOf(item) == labelOf(selected);
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Get.back(result: item),
                          child: Container(
                            color: isSel
                                ? scheme.secondary.withOpacity(0.10)
                                : Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.width_5,
                              vertical: AppSizes.height_1_8,
                            ),
                            child: Row(
                              children: [
                                if (leadingOf != null) ...[
                                  leadingOf(item),
                                  SizedBox(width: AppSizes.width_3),
                                ],
                                Expanded(
                                  child: CommonText(
                                    text: labelOf(item),
                                    maxLines: 1,
                                    textColor: isSel
                                        ? scheme.secondary
                                        : scheme.onSurface,
                                    fontWeight:
                                        isSel ? FontWeight.w600 : FontWeight.w400,
                                    fontSize: AppFontSize.size_14,
                                    fontFamily: Constant.fontFamilyNunitoSans,
                                  ),
                                ),
                                if (isSel)
                                  Icon(Icons.check_rounded,
                                      color: scheme.secondary,
                                      size: AppFontSize.size_20),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: AppSizes.height_2),
        ],
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

/// The collapsed "field" that opens a [showSelectionSheet] — a tappable row with
/// a leading [prefix], the current value (or hint), and a chevron. Theme-correct
/// fill + readable value text in both light and dark.
class PickerField extends StatelessWidget {
  final Widget prefix;
  final String? valueText;
  final String hintText;
  final VoidCallback onTap;

  const PickerField({
    super.key,
    required this.prefix,
    required this.hintText,
    required this.onTap,
    this.valueText,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Get.theme.colorScheme;
    final bool hasValue = valueText != null && valueText!.trim().isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSizes.width_3_5),
        decoration: BoxDecoration(
          color: scheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1, color: scheme.surfaceTint),
        ),
        child: Row(
          children: [
            prefix,
            Expanded(
              child: CommonText(
                text: hasValue ? valueText! : hintText,
                maxLines: 1,
                textColor: hasValue ? scheme.onSurface : scheme.surface,
                fontWeight: FontWeight.w400,
                fontSize: AppFontSize.size_12,
                fontFamily: Constant.fontFamilyNunitoSans,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.width_3),
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  color: scheme.primary, size: AppFontSize.size_22),
            ),
          ],
        ),
      ),
    );
  }
}
