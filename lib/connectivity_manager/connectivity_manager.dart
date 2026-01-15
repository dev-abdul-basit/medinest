import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetConnectivity {
  // ------------------ SINGLETON -----------------------
  static final InternetConnectivity _internetConnectivity =
      InternetConnectivity._internal();

  factory InternetConnectivity() {
    return _internetConnectivity;
  }

  InternetConnectivity._internal();

  static InternetConnectivity get shared => _internetConnectivity;

  static Connectivity? _connectivity;

  /* make connection with preference only once in application */
  Future<Connectivity?> instance() async {
    if (_connectivity != null) return _connectivity;

    _connectivity = Connectivity();

    return _connectivity;
  }

  static Future<List<ConnectivityResult>> getStatus() {
    return _connectivity!.checkConnectivity();
  }

  static Future<bool> isInternetConnect([BuildContext? context]) async {
    List<ConnectivityResult> result = await getStatus();

    if (result == ConnectivityResult.none) {
      // ignore: use_build_context_synchronously
      // Utils.showToast(context, "toastInternetConnection".tr);
      return false;
    } else {
      return true;
    }
  }
}
