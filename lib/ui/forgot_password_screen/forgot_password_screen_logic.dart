import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/utils.dart';

class ForgotPasswordScreenLogic extends GetxController {
  final formKey = GlobalKey<FormState>();
  bool isShowProgress = false;
  TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void sendVerificationLink(BuildContext context) {
    if (formKey.currentState!.validate()) {
      isShowProgress = true;
      update([Constant.idProVersionProgress]);
      _auth.sendPasswordResetEmail(email: emailController.text).then((value) {
        Debug.printLog("sendPasswordResetEmail:");
        Utils.showToast(context,
            "Reset Password link has been sent to your Email address.");
        Get.back();
      });
    }
  }
}
