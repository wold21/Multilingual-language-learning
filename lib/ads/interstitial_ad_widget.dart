import 'dart:async';

import 'package:eng_word_storage/ads/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:eng_word_storage/services/purchase_service.dart';

class InterstitialAdService {
  static final InterstitialAdService _instance =
      InterstitialAdService._internal();
  factory InterstitialAdService() => _instance;
  bool get isAdLoaded => _interstitialAd != null;

  InterstitialAd? _interstitialAd;
  bool _isAdRemoved = false;

  InterstitialAdService._internal();

  Future<bool> loadInterstitialAd({int retryCount = 3}) async {
    _isAdRemoved = await PurchaseService.instance.isAdRemoved();
    if (_isAdRemoved) {
      return false;
    }

    Completer<bool> completer = Completer<bool>();

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          completer.complete(true);
        },
        onAdFailedToLoad: (LoadAdError error) async {
          if (retryCount > 0) {
            await Future.delayed(Duration(seconds: 5));
            bool result = await loadInterstitialAd(retryCount: retryCount - 1);
            completer.complete(result);
          } else {
            completer.complete(false);
          }
        },
      ),
    );
    return completer.future;
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
