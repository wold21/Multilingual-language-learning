import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class PurchaseService {
  static final PurchaseService instance = PurchaseService._();
  PurchaseService._();

  static const String _removeAdsIdAndroid = 'remove_ads';
  static const String _removeAdsIdIOS = 'your.bundle.id.removeads';

  String get _removeAdsId =>
      Platform.isIOS ? _removeAdsIdIOS : _removeAdsIdAndroid;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final StreamController<bool> _adsRemovedController =
      StreamController<bool>.broadcast();

  Stream<bool> get adsRemovedStream => _adsRemovedController.stream;

  Future<void> init() async {
    final available = await _inAppPurchase.isAvailable();
    if (!available) return;

    _inAppPurchase.purchaseStream.listen(_handlePurchaseUpdate);
  }

  Future<void> buyRemoveAds() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      throw Exception('In-app purchases not available');
    }

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails({_removeAdsId});

    if (response.productDetails.isEmpty) {
      throw Exception('Product not found');
    }

    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: response.productDetails.first);

    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        await _savePurchaseStatus(true);
      } else {
        await _savePurchaseStatus(false);
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    });
  }

  Future<void> _savePurchaseStatus(bool purchased) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ads_removed', purchased);
    _adsRemovedController.add(purchased);
  }

  Future<bool> isAdRemoved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('ads_removed') ?? false;
  }
}
