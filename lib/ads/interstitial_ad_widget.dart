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

  Future<void> loadInterstitialAd() async {
    _isAdRemoved = await PurchaseService.instance.isAdRemoved();
    if (_isAdRemoved) {
      return; // 광고 제거된 경우 광고 로드하지 않음
    }

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Interstitial ad is not loaded yet.');
      return;
    }

    _interstitialAd!.show();
    _interstitialAd = null; // 광고가 표시된 후 null로 설정
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
