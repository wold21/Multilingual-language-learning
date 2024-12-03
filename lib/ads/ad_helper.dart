import 'dart:io';

import 'package:flutter/foundation.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/9214589741';
      } else {
        return 'ca-app-pub-7804050256012308/9530408681';
      }
    } else if (Platform.isIOS) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/2934735716';
      } else {
        return 'ca-app-pub-7804050256012308/3659969055';
      }
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/1033173712';
      } else {
        return 'ca-app-pub-7804050256012308/7464043770';
      }
    } else if (Platform.isIOS) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/4411468910';
      } else {
        return 'ca-app-pub-7804050256012308/3316354128';
      }
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/2247696110';
      } else {
        return 'ca-app-pub-7804050256012308/2159746203';
      }
    } else if (Platform.isIOS) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/3986624511';
      } else {
        return 'ca-app-pub-7804050256012308/9320152552';
      }
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
