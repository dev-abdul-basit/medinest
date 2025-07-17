import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medinest/connectivity_manager/connectivity_manager.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/helper/firestore_helper.dart';
import 'package:medinest/database/tables/user_table.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/utils.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignInController extends GetxController {
  final formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isShowProgress = false;
  bool isShowPassword = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? fcmToken;
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
      Preference.shared.setString(Preference.fcmToken, fcmToken!);
    });
    super.onInit();
  }

  login(context) async {
    if (await InternetConnectivity.isInternetConnect(context)) {
      if (formKey.currentState!.validate()) {
        try {
          isShowProgress = true;
          update([Constant.idProVersionProgress]);
          var auth = await _auth.signInWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());

          Preference.shared
              .setString(Preference.firebaseAuthUid, auth.user!.uid);
          Preference.shared
              .setString(Preference.firebaseEmail, auth.user!.email!);

          Debug.printLog(
              "Preference.shared.getProfileAdded() :${Preference.shared.getProfileAdded()}");
          if (Preference.shared.getProfileAdded()) {
            List<UserTable> userDataList =
                await DataBaseHelper.instance.getUserData(auth.user!.email!);
            if (userDataList.isNotEmpty) {
              Debug.printLog("userDataList.isNotEmpty :${userDataList.length}");
              await FireStoreHelper().onSync();
              Utils.showToast(context, "toastLogin".tr);
              isShowProgress = false;
              update([Constant.idProVersionProgress]);
              Preference.shared.setIsUserLogin(true);
              emailController.text = '';
              passwordController.text = '';
              Get.offAllNamed(AppRoutes.home,
                  parameters: {Constant.idIsFromLogIn: "true"});
            } else {
              Debug.printLog("userDataList.isEmpty :${userDataList.length}");

              emailController.text = '';
              passwordController.text = '';
              await FireStoreHelper().checkAndSyncExistingUser();
              isShowProgress = false;
              update([Constant.idProVersionProgress]);
              Utils.showToast(context, "toastLogin".tr);
              // Get.toNamed(AppRoutes.addOrEditProfile,parameters: {Constant.idIsEditProfile : "false"});
            }
          } else {
            await FireStoreHelper().checkAndSyncExistingUser();
            Utils.showToast(context, "toastLogin".tr);
            isShowProgress = false;
            update([Constant.idProVersionProgress]);
            emailController.text = '';
            passwordController.text = '';
          }
        } catch (firebaseAuthException) {
          isShowProgress = false;
          update([Constant.idProVersionProgress]);
          if (firebaseAuthException.toString().contains('wrong-password')) {
            Utils.showToast(context, 'Invalid Password, please try again!');
          } else if (firebaseAuthException
              .toString()
              .contains('user-not-found')) {
            Utils.showToast(
                context, 'User not found, please check your email again!');
          }else if (firebaseAuthException
              .toString()
              .contains('too-many-requests')) {
            Utils.showToast(
                context, 'You have tried wrong password too many times, please try again after some time');
          } else {
            Utils.showToast(context, firebaseAuthException.toString());
          }
        }
      }
    } else {
      Utils.showToast(context, "txtCheckYourInternetConnectivity".tr);
    }
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
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
            Preference.shared.setString(
                Preference.firebaseAuthUid, userCredential.user!.uid);
            Preference.shared.setString(
                Preference.firebaseEmail, userCredential.user!.email!);

            if (Preference.shared.getProfileAdded()) {
              List<UserTable> userDataList = await DataBaseHelper.instance
                  .getUserData(userCredential.user!.email!);
              if (userDataList.isNotEmpty) {
                await FireStoreHelper().onSync();
                isShowProgress = false;
                update([Constant.idProVersionProgress]);
                Utils.showToast(context, "toastLogin".tr);
                Preference.shared.setIsUserLogin(true);
                emailController.text = '';
                passwordController.text = '';
                Get.offAllNamed(AppRoutes.home,
                    parameters: {Constant.idIsFromLogIn: "true"});
              } else {
                await FireStoreHelper().checkAndSyncExistingUser();
                isShowProgress = false;
                update([Constant.idProVersionProgress]);
                emailController.text = '';
                passwordController.text = '';
                Utils.showToast(context, "toastLogin".tr);
                //Get.toNamed(AppRoutes.addOrEditProfile,parameters: {Constant.idIsEditProfile : "false"});
              }
            } else {
              await FireStoreHelper().checkAndSyncExistingUser();
              Utils.showToast(context, "toastLogin".tr);
              emailController.text = '';
              passwordController.text = '';
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
      } on Exception catch (e) {
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
    if (await InternetConnectivity.isInternetConnect(context)) {
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
          List<UserTable> userDataList =
              await DataBaseHelper.instance.getUserData(auth.user!.email!);
          if (userDataList.isNotEmpty) {
            await FireStoreHelper().onSync();
            Utils.showToast(context, "toastLogin".tr);
            Preference.shared
                .setString(Preference.firebaseAuthUid, auth.user!.uid);
            Preference.shared
                .setString(Preference.firebaseEmail, auth.user!.email!);
            Preference.shared.setIsUserLogin(true);
            isShowProgress = false;
            update([Constant.idProVersionProgress]);
            emailController.text = '';
            passwordController.text = '';
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
            emailController.text = '';
            passwordController.text = '';
            Utils.showToast(context, "toastLogin".tr);
            // Get.toNamed(AppRoutes.addOrEditProfile,parameters: {Constant.idIsEditProfile : "false"});
          }
        } else {
          Preference.shared
              .setString(Preference.firebaseAuthUid, auth.user!.uid);
          Preference.shared
              .setString(Preference.firebaseEmail, auth.user!.email!);
          await FireStoreHelper().checkAndSyncExistingUser();
          Utils.showToast(context, "toastLogin".tr);
          isShowProgress = false;
          update([Constant.idProVersionProgress]);
          emailController.text = '';
          passwordController.text = '';
        }

        return auth;
      } catch (e) {
        isShowProgress = false;
        update([Constant.idProVersionProgress]);
        Utils.showToast(context, e.toString());
      }
    } else {
      Utils.showToast(context, "txtCheckYourInternetConnectivity".tr);
    }
  }

  Future<void> logoutGoogle() async {
    await _googleSignIn.signOut();
    // Get.back();
  }

  void toggleShowHidePassword() {
    isShowPassword = !isShowPassword;
    update([Constant.idPasswordInput]);
  }
}
