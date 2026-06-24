import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:medinest/Widgets/common_text.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

/// Result of the dosage sheet: how much (amount) of which unit per dose.
class DosageResult {
  final String amount;
  final String unit;
  const DosageResult(this.amount, this.unit);
}

/// A focused "How much per dose?" sheet that replaces the bare, confusing
/// "Add Dosage" text field. It combines the amount (with − / + steppers and
/// quick presets) and the unit picker in one clear, guided step.
Future<DosageResult?> showDosageSheet({
  String? amount,
  String? unit,
  required List<String> units,
}) {
  return Get.bottomSheet<DosageResult>(
    _DosageSheet(initialAmount: amount, initialUnit: unit, units: units),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _DosageSheet extends StatefulWidget {
  final String? initialAmount;
  final String? initialUnit;
  final List<String> units;

  const _DosageSheet({
    this.initialAmount,
    this.initialUnit,
    required this.units,
  });

  @override
  State<_DosageSheet> createState() => _DosageSheetState();
}

class _DosageSheetState extends State<_DosageSheet> {
  late final TextEditingController _amountCtrl;
  late String _unit;

  @override
  void initState() {
    super.initState();
    final String seed = (widget.initialAmount?.trim().isNotEmpty ?? false)
        ? widget.initialAmount!.trim()
        : '1';
    _amountCtrl = TextEditingController(text: seed);
    _unit = (widget.initialUnit != null && widget.units.contains(widget.initialUnit))
        ? widget.initialUnit!
        : (widget.units.isNotEmpty ? widget.units.first : '');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  void _bump(double delta) {
    final double current = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    double next = current + delta;
    if (next < 0) next = 0;
    _amountCtrl.text = _fmt(next);
    setState(() {});
  }

  void _setPreset(String v) {
    _amountCtrl.text = v;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Get.theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: AppSizes.fullHeight * 0.8),
        decoration: BoxDecoration(
          color: scheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                      text: 'txtDosageSheetTitle'.tr,
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
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.width_5,
                  AppSizes.height_2_5,
                  AppSizes.width_5,
                  AppSizes.height_2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Amount stepper ──
                    Row(
                      children: [
                        _stepButton(scheme, Icons.remove_rounded, () => _bump(-1)),
                        Expanded(
                          child: TextField(
                            controller: _amountCtrl,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]')),
                            ],
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: AppFontSize.size_28,
                              fontFamily: Constant.fontFamilyNunitoSans,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                          ),
                        ),
                        _stepButton(scheme, Icons.add_rounded, () => _bump(1)),
                      ],
                    ),
                    SizedBox(height: AppSizes.height_2),
                    // ── Quick presets ──
                    Wrap(
                      spacing: 8,
                      children: ['0.5', '1', '2', '3']
                          .map((p) => _presetChip(scheme, p))
                          .toList(),
                    ),
                    SizedBox(height: AppSizes.height_3),
                    CommonText(
                      text: 'txtUnit'.tr,
                      textColor: scheme.surface,
                      fontWeight: FontWeight.w500,
                      fontSize: AppFontSize.size_12,
                    ),
                    SizedBox(height: AppSizes.height_1_5),
                    // ── Unit chips ──
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.units.map((u) => _unitChip(scheme, u)).toList(),
                    ),
                    SizedBox(height: AppSizes.height_3),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: AppSizes.height_1_8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          final String amount = _amountCtrl.text.trim().isEmpty
                              ? '1'
                              : _amountCtrl.text.trim();
                          Get.back(result: DosageResult(amount, _unit));
                        },
                        child: CommonText(
                          text: 'txtDone'.tr,
                          textColor: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: AppFontSize.size_15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepButton(ColorScheme scheme, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: AppSizes.height_5_5,
        height: AppSizes.height_5_5,
        decoration: BoxDecoration(
          color: scheme.surfaceVariant,
          shape: BoxShape.circle,
          border: Border.all(color: scheme.primary.withOpacity(0.4)),
        ),
        child: Icon(icon, color: scheme.primary, size: AppFontSize.size_24),
      ),
    );
  }

  Widget _presetChip(ColorScheme scheme, String value) {
    final bool selected = _amountCtrl.text.trim() == value;
    return GestureDetector(
      onTap: () => _setPreset(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? scheme.secondary : scheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? scheme.secondary : scheme.surfaceTint,
          ),
        ),
        child: CommonText(
          text: value,
          textColor: selected ? Colors.white : scheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: AppFontSize.size_13,
        ),
      ),
    );
  }

  Widget _unitChip(ColorScheme scheme, String unit) {
    final bool selected = _unit == unit;
    return GestureDetector(
      onTap: () => setState(() => _unit = unit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? scheme.secondary : scheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? scheme.secondary : scheme.surfaceTint,
          ),
        ),
        child: CommonText(
          text: unit.capitalizeFirst ?? unit,
          textColor: selected ? Colors.white : scheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: AppFontSize.size_12,
        ),
      ),
    );
  }
}
