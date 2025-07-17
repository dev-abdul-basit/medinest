import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/utils/color.dart';

class ProgressDialog extends StatelessWidget {
  final Widget? child;
  final bool? inAsyncCall;
  final double? opacity;
  final Color? color;
  final Animation<Color>? valueColor;

  const ProgressDialog({
    super.key,
    @required this.child,
    @required this.inAsyncCall,
    this.opacity = 0.0,
    this.color = Colors.black,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    widgetList.add(child!);
    if (inAsyncCall!) {
      final modal = Stack(
        children: [
          Opacity(
            opacity: 0.5,
            child: ModalBarrier(dismissible: false, color: color),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow:   const [
                  BoxShadow(
                    color: AppColor.txtColor999,
                    spreadRadius: 0.1,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 5.0,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(30),
              height: 75,
              width: 75,
              child: CircularProgressIndicator(
                color: Get.theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      );
      widgetList.add(modal);
    }
    return Stack(
      children: widgetList,
    );
  }
}
