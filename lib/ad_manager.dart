import 'dart:io';

//App ID: ca-app-pub-5313084330191940~7457689556
//Interstitial Ad: ca-app-pub-5313084330191940/7642071126
//TEST App ID: ca-app-pub-3940256099942544~3347511713
//TEST Interstsitial Ad: ca-app-pub-3940256099942544/1033173712


class AdManager{
  static String get appId{
    if(Platform.isAndroid){
      return "ca-app-pub-5313084330191940~7457689556";
    }
    else {
      throw new UnsupportedError("Unsupported platform (from appId)");
    }
  }
  static String get interstitialAdUnitId{
    if(Platform.isAndroid){
      return "ca-app-pub-5313084330191940/7642071126";
    }
    else {
      throw new UnsupportedError("Unsupported platform (from interstitialAdUnitId)");
    }
  }
}