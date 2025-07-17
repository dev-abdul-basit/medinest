import 'package:flutter/material.dart';
import 'package:medinest/utils/color.dart';

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final BorderRadius borderRadius;

  const CustomTextFormField({
    super.key,
    required this.labelText,
    required this.prefixIcon,
    required this.suffixIcon,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  Widget build(BuildContext context) {
    final focusedBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: AppColor.colorPrimaryLight),
    );
    final enabledBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: AppColor.gray),
    );

    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: focusedBorder,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
      ),
    );
  }
}
