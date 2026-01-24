import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/sizer_utils.dart';

import '../utils/color.dart';

class CommonTextFormField extends StatelessWidget {
  final String hintText;
  final String validatorText;
  final String prefixIcon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final Color fillColor;
  final Function(String)? onTextChanged;
  final double radius;
  final int maxLines;
  final FocusNode? focusNode;
  final String? Function(String? value)? validator;

  const CommonTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.fillColor,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.onTextChanged,
    this.radius = 5,
    this.maxLines = 1,
    this.validatorText = "",
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      cursorColor: AppColor.colorPrimaryLight,
      style: TextStyle(
        fontSize: AppFontSize.size_12,
        fontWeight: FontWeight.w400,
        color: AppColor.colorPrimaryLight,
        fontFamily: Constant.fontFamilyNunitoSans,
      ),
      maxLines: maxLines,
      onChanged: onTextChanged,
      enabled: enabled,
      validator: validator ??
          (String? value) {
            if (value == null || value.isEmpty) {
              return validatorText;
            }
            return null;
          },
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: AppFontSize.size_15,
          fontWeight: FontWeight.w400,
          color: AppColor.gray,
          fontFamily: Constant.fontFamilyNunitoSans,
        ),
        errorStyle: TextStyle(
          fontSize: AppFontSize.size_14,
          fontWeight: FontWeight.w400,
          color: AppColor.colorSecondaryLight,
          fontFamily: Constant.fontFamilyNunitoSans,
        ),
        contentPadding: EdgeInsetsDirectional.fromSTEB(
          0, (maxLines > 1) ? AppSizes.height_1 : 0,
           AppSizes.width_15,
           (maxLines > 1) ? AppSizes.height_1 : 0,
        ),
        prefixIcon: Container(
          //padding: EdgeInsets.all(AppSizes.setHeight(12)),
          padding: (maxLines > 2)
              ? EdgeInsets.only(
                  bottom: AppSizes.height_1,
                  left: AppSizes.height_1,
                  right: AppSizes.height_1,
                  top: 0)
              : EdgeInsets.all(AppSizes.height_1),
          margin: EdgeInsets.only(
              top: 0,
              bottom: (maxLines > 1)
                  ? (maxLines == 2)
                      ? AppSizes.height_1
                      : AppSizes.height_1
                  : 0),
          child: Image.asset(
            prefixIcon,
            height: AppSizes.height_5,
            width: AppSizes.height_5,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColor.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColor.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColor.transparent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColor.transparent),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColor.transparent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColor.transparent),
        ),
      ),
    );
  }
}

class CommonTextFormFieldWithSuffix extends StatelessWidget {
  final String hintText;
  final String validatorText;
  final String validatorType;
  final String prefixIcon;
  final String suffixIcon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final Color fillColor;
  final Function(String)? onTextChanged;
  final double radius;
  final int maxLines;
  final BorderRadius borderRadius;
  final void Function()? onTapSuffix;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool readOnly;
  final bool shouldValidate;

  const CommonTextFormFieldWithSuffix(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.prefixIcon,
      required this.fillColor,
      this.keyboardType,
      this.suffixIcon = "",
      this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.shouldValidate = false,
    this.onTextChanged,
    this.radius = 5,
    this.maxLines = 1,
    this.validatorText = "",
    this.validatorType = Constant.validationTypeEmpty,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.inputFormatters,
    this.onTapSuffix,
    this.maxLength,
    this.onTap});

  @override
  Widget build(BuildContext context) {
    final focusedBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: Get.theme.colorScheme.primary,width: 0.5),
    );
    final enabledBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: Get.theme.colorScheme.surfaceTint,width: 0.5),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: Get.theme.colorScheme.primary,width: 0.5),
    );
    return TextFormField(
      onTap: onTap,
      readOnly: readOnly,
      controller: controller,
      autofocus: autofocus,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textInputAction: maxLines>1?TextInputAction.newline:null,
      textCapitalization: TextCapitalization.sentences,
      cursorColor: Get.theme.colorScheme.primary,
      style: TextStyle(
        fontSize: AppFontSize.size_14,
        fontWeight: FontWeight.w400,
        color: Get.theme.colorScheme.primary,
        fontFamily: Constant.fontFamilyNunitoSans,
      ),
      maxLines: maxLines,
      onChanged: onTextChanged,
      enabled: enabled,
      textAlignVertical: TextAlignVertical.top,
      inputFormatters: null,//inputFormatters,
      validator: (String? value) {
        if (value == null || value.isEmpty || value.trim().isEmpty) {
          return shouldValidate?validatorText:null;
        } else if (validatorType == Constant.validationTypeEmail &&
            !value.isValidEmail()) {
          return validatorText;
        } else if (validatorType == Constant.validationTypePassword &&
            !value.isValidPassword()) {
          return validatorText;
        } else if (validatorType == Constant.validationTypePhone &&
            !value.isValidPhone()) {
          return validatorText;
        }
        return null;
      },
      decoration: InputDecoration(
          filled: true,
          fillColor: fillColor,
          hintText: hintText,
          counterText: '',
          hintStyle: TextStyle(
            fontSize: AppFontSize.size_12,
            fontWeight: FontWeight.w500,
            color: Get.theme.colorScheme.surface,
            fontFamily: Constant.fontFamilyNunitoSans,
          ),
          errorMaxLines: 3,
          errorStyle: TextStyle(
            fontSize: AppFontSize.size_8,
            fontWeight: FontWeight.w600,
            color: Get.theme.colorScheme.onSecondary,
            fontFamily: Constant.fontFamilyNunitoSans,
          ),
          contentPadding: EdgeInsets.all(AppSizes.width_3_8),
          prefixIcon: maxLines == 1
              ? Padding(
                  padding: EdgeInsetsDirectional.only(
                      top: AppSizes.width_3,
                      bottom: AppSizes.width_3,
                      start: AppSizes.width_5,
                      end: AppSizes.width_4),
                  child: Image.asset(
                    prefixIcon,
                    height: AppSizes.height_2_5,
                    width: AppSizes.height_2_5,
                  ),
                )
              : maxLines == 4
                  ? Container(
                      margin:
                          EdgeInsetsDirectional.only(start: AppSizes.width_5,end: AppSizes.width_2_8,top: 0, bottom: AppSizes.height_9),
                      child: Image.asset(
                        prefixIcon,
                        height: AppSizes.height_2_8,
                        width: AppSizes.height_2_8,
                      ),
                    )
                  : maxLines == 6
                      ? Container(
                          margin: EdgeInsetsDirectional.only(
                              start: AppSizes.height_2_2,
                              top: AppSizes.height_1,
                              end: AppSizes.height_2,
                              bottom: AppSizes.height_15),
                          child: Image.asset(
                            prefixIcon,
                            height: AppSizes.height_2_5,
                            width: AppSizes.height_2_5,
                          ),
                        )
                      : Container(
            margin:
            EdgeInsetsDirectional.only(start: AppSizes.width_5_5,end: AppSizes.width_3,top: AppSizes.height_1, bottom: AppSizes.height_4),
                          child: Image.asset(
                            prefixIcon,
                            height: AppSizes.height_2_5,
                            width: AppSizes.height_2_5,
                          ),
                        ),
          suffixIcon: (suffixIcon != "")
              ? Padding(
                  padding: EdgeInsets.all(AppSizes.height_1_5),
                  child: InkWell(
                    onTap: onTapSuffix,
                    child: Image.asset(
                      suffixIcon,
                      height: AppSizes.height_2_5,
                      width: AppSizes.height_2_5,
                    ),
                  ),
                )
              : const SizedBox(),
          border: focusedBorder,
          enabledBorder: enabledBorder,
          focusedBorder: focusedBorder,
          errorBorder: errorBorder,
          focusedErrorBorder: focusedBorder),
    );
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

extension PasswordValidator on String {
  bool isValidPassword() {
    return RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(this);
  }
}

extension PhoneValidator on String {
  bool isValidPhone() {
    return RegExp(r'(\+\d{1,2}\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$')
        .hasMatch(this);
  }
}
// class CommonTextFormFieldWitOutPrefix extends StatelessWidget {
//   final String hintText;
//   final String validatorText;
//   final TextEditingController controller;
//   final TextInputType? keyboardType;
//   final bool obscureText;
//   final bool autofocus;
//   final bool enabled;
//   final Color fillColor;
//   final Function(String)? onTextChanged;
//   final double radius;
//   final int maxLines;
//
//   const CommonTextFormFieldWitOutPrefix({
//     super.key,
//     required this.controller,
//     required this.hintText,
//     required this.fillColor,
//     this.keyboardType,
//     this.obscureText = false,
//     this.autofocus = false,
//     this.enabled = true,
//     this.onTextChanged,
//     this.radius = 5,
//     this.maxLines = 1,
//     this.validatorText = "",
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       autofocus: autofocus,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       cursorColor: AppColor.primary,
//       style: TextStyle(
//         fontSize: AppSizes.setFontSize(15),
//         fontWeight: FontWeight.w400,
//         color: AppColor.primary,
//         fontFamily: Constant.fontFamilyInter,
//       ),
//       maxLines: maxLines,
//       onChanged: onTextChanged,
//       enabled: enabled,
//       validator: (String? value) {
//         if (value == null || value.isEmpty) {
//           return validatorText;
//         }
//         return null;
//       },
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: fillColor,
//         hintText: hintText,
//         hintStyle: TextStyle(
//           fontSize: AppSizes.setFontSize(15),
//           fontWeight: FontWeight.w400,
//           color: AppColor.txtGrey,
//           fontFamily: Constant.fontFamilyInter,
//         ),
//         errorStyle: TextStyle(
//           fontSize: AppSizes.setFontSize(14),
//           fontWeight: FontWeight.w400,
//           color: AppColor.txtRed,
//           fontFamily: Constant.fontFamilyInter,
//         ),
//         contentPadding: EdgeInsets.only(
//           right: AppSizes.setWidth(12),
//           left: AppSizes.setWidth(12),
//           top: (maxLines > 1) ? AppSizes.setHeight(14) : 0,
//           bottom: (maxLines > 1) ? AppSizes.setHeight(14) : 0,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(radius),
//           borderSide: const BorderSide(color: AppColor.transparent),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(radius),
//           borderSide: const BorderSide(color: AppColor.transparent),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(radius),
//           borderSide: const BorderSide(color: AppColor.transparent),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(radius),
//           borderSide: const BorderSide(color: AppColor.transparent),
//         ),
//         disabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(radius),
//           borderSide: const BorderSide(color: AppColor.transparent),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(radius),
//           borderSide: const BorderSide(color: AppColor.transparent),
//         ),
//       ),
//     );
//   }
// }
