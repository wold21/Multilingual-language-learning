import 'dart:io';
import 'package:eng_word_storage/utils/toast_util.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    try {
      debugPrint('PurchaseService init start'); // 시작 로그
      ToastUtils.show(
        message: 'PurchaseService init start',
        type: ToastType.info,
      );
      final available = await _inAppPurchase.isAvailable();
      debugPrint('PurchaseService available: $available'); // 가용성 체크 로그
      ToastUtils.show(
        message: 'PurchaseService available',
        type: ToastType.info,
      );

      if (!available) {
        debugPrint('PurchaseService not available');
        ToastUtils.show(
          message: 'PurchaseService not available',
          type: ToastType.info,
        );
        return;
      }

      _inAppPurchase.purchaseStream.listen(_handlePurchaseUpdate);
      final isRemoved = await isAdRemoved();
      debugPrint('PurchaseService isAdRemoved: $isRemoved'); // 광고 제거 상태 로그
      ToastUtils.show(
        message: 'PurchaseService isAdRemoved: $isRemoved',
        type: ToastType.info,
      );

      _adsRemovedController.add(isRemoved);
      await restorePurchases();
      debugPrint('PurchaseService init complete'); // 완료 로그
      ToastUtils.show(
        message: 'PurchaseService init complete',
        type: ToastType.info,
      );
    } catch (e) {
      debugPrint('PurchaseService init error: $e'); // 에러 로그
      ToastUtils.show(
        message: 'PurchaseService init error $e',
        type: ToastType.info,
      );
    }
  }

  Future<void> buyRemoveAds() async {
    // 이미 구매했는지 확인
    if (await isAdRemoved()) {
      ToastUtils.show(
        message: '이미 구매한 상품입니다.',
        type: ToastType.info,
      );
      return;
    }

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
    ToastUtils.show(
      message: 'restorePurchases',
      type: ToastType.success,
    );
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        await _savePurchaseStatus(true);
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
