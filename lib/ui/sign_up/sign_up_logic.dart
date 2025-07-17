import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medinest/connectivity_manager/connectivity_manager.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/helper/firestore_helper.dart';
import 'package:medinest/database/tables/user_table.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/utils.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignUpLogic extends GetxController {
  final formKey = GlobalKey<FormState>();
  bool isShowProgress = false;
  String? fcmToken;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isShowPassword = false;
  bool isShowConformPassword = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  @override
  void onInit() {
    FirebaseMessaging firebaseMessaging =
        FirebaseMessaging.instance; // Change here
    firebaseMessaging.getToken().then((token) {
      fcmToken = token;
    });
    super.onInit();
  }

  void singUp(context) async {
    if (await InternetConnectivity.isInternetConnect(context)) {
      if (formKey.currentState!.validate()) {
        if (confirmPasswordController.text != passwordController.text) {
          Utils.showToast(context, 'Password must be same.');
          return;
        }
        isShowProgress = true;
        update([Constant.idProVersionProgress]);

        try {
          var auth = await _auth.createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: confirmPasswordController.text.trim());
          Preference.shared
              .setString(Preference.firebaseAuthUid, auth.user!.uid);
          Preference.shared
              .setString(Preference.firebaseEmail, auth.user!.email!);

          if (Preference.shared.getProfileAdded()) {
            List<UserTable> userDataList =
                await DataBaseHelper.instance.getUserData(auth.user!.email!);
            if (userDataList.isNotEmpty) {
              await FireStoreHelper().onSync();
              isShowProgress = false;
              update([Constant.idProVersionProgress]);
              Utils.showToast(context, "You are successfully logged in");
              Preference.shared.setIsUserLogin(true);
              Get.offAllNamed(AppRoutes.home,
                  parameters: {Constant.idIsFromLogIn: "true"});
            } else {
              await FireStoreHelper().checkAndSyncExistingUser();
              Utils.showToast(context, "You are successfully logged in");
              isShowProgress = false;
              update([Constant.idProVersionProgress]);
              //Get.toNamed(AppRoutes.addOrEditProfile,parameters: {Constant.idIsEditProfile : "false"});
            }
          } else {
            await FireStoreHelper().checkAndSyncExistingUser();
            isShowProgress = false;
            update([Constant.idProVersionProgress]);
            Utils.showToast(context, "You are successfully logged in");
          }
          emailController.text = '';
          passwordController.text = '';
          confirmPasswordController.text = '';
        } catch (firebaseAuthException) {
          isShowProgress = false;
          update([Constant.idProVersionProgress]);
          if (firebaseAuthException
              .toString()
              .contains('email-already-in-use')) {
            Utils.showToast(context,
                'This Email address is already used try with another Email');
          } else {
            Utils.showToast(context, firebaseAuthException.toString());
          }
        }
      }
    } else {
      Utils.showToast(context, "txtCheckYourInternetConnectivity".tr);
    }
  }

  loginWithGoogle(context) async {
    if (await InternetConnectivity.isInternetConnect(context)) {
      try {
        isShowProgress = true;
        update([Constant.idProVersionProgress]);
        await _auth.signOut();
        await _googleSignIn.signOut();
        GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

        if (googleSignInAccount != null) {
          GoogleSignInAuthentication googleSignInAuthentication =
              await googleSignInAccount.authentication;

          AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );
          UserCredential? userCredential =
              await _auth.signInWithCredential(credential).catchError((onErr) {
            isShowProgress = false;

            return Utils.showToast(context, onErr.toString());
          });
          if (userCredential.user != null) {
            if (Preference.shared.getProfileAdded()) {
              List<UserTable> userDataList = await DataBaseHelper.instance
                  .getUserData(userCredential.user!.uid);
              if (userDataList.isNotEmpty) {
                await FireStoreHelper().onSync();
                Preference.shared.setString(
                    Preference.firebaseAuthUid, userCredential.user!.uid);
                Preference.shared.setString(
                    Preference.firebaseEmail, userCredential.user!.email!);
                isShowProgress = false;
                update([Constant.idProVersionProgress]);
                Utils.showToast(context, "toastLogin".tr);
                Preference.shared.setIsUserLogin(true);
                Get.offAllNamed(AppRoutes.home,
                    parameters: {Constant.idIsFromLogIn: "true"});
              } else {
                Preference.shared.setString(
                    Preference.firebaseAuthUid, userCredential.user!.uid);
                Preference.shared.setString(
                    Preference.firebaseEmail, userCredential.user!.email!);
                await FireStoreHelper().checkAndSyncExistingUser();
                isShowProgress = false;
                update([Constant.idProVersionProgress]);
                Utils.showToast(context, "toastLogin".tr);
                //Get.toNamed(AppRoutes.addOrEditProfile,parameters: {Constant.idIsEditProfile : "false"});
              }
            } else {
              Preference.shared.setString(
                  Preference.firebaseAuthUid, userCredential.user!.uid);
              Preference.shared.setString(
                  Preference.firebaseEmail, userCredential.user!.email!);
              await FireStoreHelper().checkAndSyncExistingUser();
              Utils.showToast(context, "toastLogin".tr);
              isShowProgress = false;
              update([Constant.idProVersionProgress]);
            }
          } else {
            isShowProgress = false;
          }
        } else {
          Utils.showToast(context, "Something Went Wrong");
          isShowProgress = false;
        }
        emailController.text = '';
        passwordController.text = '';
        confirmPasswordController.text = '';
      } catch (e) {
        Utils.showToast(context, e.toString());

        isShowProgress = false;
        update([Constant.idProVersionProgress]);
      } finally {
        isShowProgress = false;
        update([Constant.idProVersionProgress]);
      }
    } else {
      Utils.showToast(context, "txtCheckYourInternetConnectivity".tr);
    }
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  loginWithApple(context) async {
    try {
      isShowProgress = true;
      update([Constant.idProVersionProgress]);

      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
      var auth =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      if (Preference.shared.getProfileAdded()) {
        List<UserTable> userDataList = await DataBaseHelper.instance
            .getUserData(
                auth.user!.email); //6whdgdrg3c@privatereley.appleid.com
        if (userDataList.isNotEmpty) {
          await FireStoreHelper().onSync();
          Preference.shared.setIsUserLogin(true);
          Preference.shared
              .setString(Preference.firebaseAuthUid, auth.user!.uid);
          Preference.shared
              .setString(Preference.firebaseEmail, auth.user!.email!);
          Utils.showToast(context, "toastLogin".tr);
          isShowProgress = false;
          Get.offAllNamed(AppRoutes.home,
              parameters: {Constant.idIsFromLogIn: "true"});
        } else {
          Preference.shared
              .setString(Preference.firebaseAuthUid, auth.user!.uid);
          Preference.shared
              .setString(Preference.firebaseEmail, auth.user!.email!);
          await FireStoreHelper().checkAndSyncExistingUser();
          isShowProgress = false;
          update([Constant.idProVersionProgress]);
          Utils.showToast(context, "toastLogin".tr);
          //Get.toNamed(AppRoutes.addOrEditProfile,parameters: {Constant.idIsEditProfile : "false"});
        }
      } else {
        Preference.shared.setString(Preference.firebaseAuthUid, auth.user!.uid);
        Preference.shared
            .setString(Preference.firebaseEmail, auth.user!.email!);
        await FireStoreHelper().checkAndSyncExistingUser();
        isShowProgress = false;
        update([Constant.idProVersionProgress]);
        Utils.showToast(context, "toastLogin".tr);
      }
      emailController.text = '';
      passwordController.text = '';
      confirmPasswordController.text = '';
      update([Constant.idProVersionProgress]);
      return auth;
    } catch (e) {
      isShowProgress = false;
      update([Constant.idProVersionProgress]);
      Utils.showToast(context, e.toString());
    }
  }

  void toggleShowHidePassword() {
    isShowPassword = !isShowPassword;
    update([Constant.idPasswordInput]);
  }

  void toggleShowHideConformPassword() {
    isShowConformPassword = !isShowConformPassword;
    update([Constant.idConfirmPasswordInput]);
  }
}
