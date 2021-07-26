import 'dart:io';

class AdManager{
  static String get appId{
    if(Platform.isAndroid){
      return "REDACTED";
    }
    else {
      throw new UnsupportedError("Unsupported platform (from appId)");
    }
  }
  static String get interstitialAdUnitId{
    if(Platform.isAndroid){
      return "REDACTED";
    }
    else {
      throw new UnsupportedError("Unsupported platform (from interstitialAdUnitId)");
    }
  }
}
