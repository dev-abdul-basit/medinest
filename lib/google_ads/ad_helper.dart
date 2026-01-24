import 'dart:io';

import 'package:medinest/utils/debug.dart';



class AdHelper {
  static String get bannerAdUnitId {
    if (Debug.googleAd) {
      if (Platform.isAndroid) {
        return "ca-app-pub-3548515470103930/2056144978";///Enter your AdMobe Banner ad id for Android Here
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2934735716";///Enter your AdMobe Banner ad id for IOS Here
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      return "";
    }
  }

  static String get interstitialAdUnitId {
    if (Debug.googleAd) {
      if (Platform.isAndroid) {
        return "ca-app-pub-3548515470103930/4429875492";///Enter your Interstitial Banner ad id for Android Here
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/4411468910";///Enter your Interstitial Banner ad id for IOS Here
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      return "";
    }
  }

}