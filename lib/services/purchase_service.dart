import 'dart:io';
import 'package:eng_word_storage/utils/toast_util.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
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
    try {
      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        throw Exception('In-app purchases not available');
      }
      _inAppPurchase.purchaseStream.listen(_handlePurchaseUpdate);
      final isRemoved = await isAdRemoved();
      _adsRemovedController.add(isRemoved);
      await restorePurchases();
    } catch (e) {
      debugPrint('PurchaseService init error: $e');
    }
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

  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        await _savePurchaseStatus(true);
        String status = purchaseDetails.status == PurchaseStatus.purchased
            ? 'purchased'
            : 'purchaseRestored';
        ToastUtils.show(
          message: 'setting.massages.$status'.tr(),
          type: ToastType.success,
        );
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        await _savePurchaseStatus(false);
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }

    // 상태 변경 후 스트림 업데이트
    _adsRemovedController.add(await isAdRemoved());
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
