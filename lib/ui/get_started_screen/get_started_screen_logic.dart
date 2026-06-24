import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
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
import 'package:medinest/main.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/utils.dart';

import '../../services/google_auth_service.dart';
import '../../connectivity_manager/connectivity_manager.dart';
import '../../database/helper/database_helper.dart';
import '../../database/helper/firestore_helper.dart';
import '../../database/tables/user_table.dart';
import '../../routes/app_routes.dart';
import '../../services/google_auth_service.dart';
import '../../utils/constant.dart';
import '../../utils/preference.dart';
import '../../utils/utils.dart';

class GetStartedScreenLogic extends GetxController {
  bool isShowProgress = false;
  bool isShowPassword = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? fcmToken;

  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: <String>[
  //     'email',
  //   ],
  // );

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

  /// F07 — deferred sign-in: let the user reach value (their first reminder)
  /// without an account. Sign-in is offered later for backup & sync. We commit
  /// the get-started step so they aren't shown this screen again, then hand off
  /// to the first-medicine screen.
  void continueAsGuest() {
    Preference.shared.setIsGetStarted(true);
    // A returning guest (already onboarded, e.g. after signing out) keeps all
    // their local data and goes straight Home — no re-onboarding. Only a true
    // first-run guest sees the first-medicine screen.
    if (Preference.shared.getFirstMedicineCreated() ||
        Preference.shared.getProfileAdded()) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offNamed(AppRoutes.firstMedicine);
    }
  }

  /// Google Sign-In (Using Centralized Service)

  loginWithGoogle(BuildContext context) async {
    if (!await InternetConnectivity.isInternetConnect(context)) {
      Utils.showToast(context, "txtCheckYourInternetConnectivity".tr);
      return;
    }

    try {
      isShowProgress = true;
      update([Constant.idProVersionProgress]);

      // Call your GoogleAuthService (handles auth + Firebase + prefs)
      final result = await GoogleAuthService.instance.signInWithGoogle();

      if (result.isSuccess && result.credential != null) {
        // Account isolation: if a DIFFERENT account than the one that owns the
        // current local data signs in, swap out the local data first so the new
        // user never sees the previous account's data.
        await _isolateLocalDataForAccount(result.credential!.user!.uid);

        // Firestore sync & profile checks
        if (Preference.shared.getProfileAdded()) {
          List<UserTable> userDataList = await DataBaseHelper.instance
              .getUserData(result.credential!.user!.email!);

          if (userDataList.isNotEmpty) {
            await FireStoreHelper().onSync();
            Preference.shared.setIsGetStarted(true);
            Preference.shared.setIsUserLogin(true);
            Utils.showToast(context, "toastLogin".tr);
            Get.offAllNamed(
              AppRoutes.home,
              parameters: {Constant.idIsFromLogIn: "true"},
            );
          } else {
            Preference.shared.setIsGetStarted(true);
            await FireStoreHelper().checkAndSyncExistingUser();
            Utils.showToast(context, "toastLogin".tr);
            // Optionally navigate to add profile screen
          }
        } else {
          Preference.shared.setIsGetStarted(true);
          await FireStoreHelper().checkAndSyncExistingUser();
          Utils.showToast(context, "toastLogin".tr);
        }
      } else if (result.isCancelled) {
        Utils.showToast(context, "Google Sign-In cancelled");
      } else if (result.errorMessage != null) {
        Utils.showToast(context, result.errorMessage!);
      }
    } catch (e) {
      Utils.showToast(context, e.toString());
    } finally {
      isShowProgress = false;
      update([Constant.idProVersionProgress]);
    }
  }

  /// Account isolation. If the local data belongs to a DIFFERENT account than
  /// the one signing in, clear it first (the previous owner's data is safe in
  /// their own cloud) so accounts never see each other's data. Guest-owned data
  /// (owner == null) is claimed by the signing-in account. Always records the
  /// new owner so the next sign-in can compare.
  Future<void> _isolateLocalDataForAccount(String uid) async {
    final String? owner = Preference.shared.getDataOwnerUid();
    if (owner != null && owner != uid) {
      await DataBaseHelper.instance.clearAllUserData();
      await flutterLocalNotificationsPlugin.cancelAll();
      await Preference.shared.clearSelfMemberId();
      Preference.shared.setProfileAdded(false);
      Debug.printLog("Account switch: cleared $owner's local data for $uid");
    }
    await Preference.shared.setDataOwnerUid(uid);
  }

  Future<void> logoutGoogle() async {
    await GoogleAuthService.instance.signOut();

    // await _googleAuthService.signOut();
  }

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
}
