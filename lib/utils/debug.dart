import 'dart:developer';

class Debug {
  ///|>==|>==|> Set all debug variable false when you make release build. <|==<|==<|

  static const debug = true;
  static const googleAd = true;//set this to false to disable ads
  static const sandboxVerifyRecieptUrl = false;


  static printLog(String str, [error]) {
    if (debug) log(str,error: error);
    // print("$str : $error");
  }
}
