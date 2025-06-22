import 'dart:async';
import 'package:focus_news/services/iap_service.dart';
import 'package:focus_news/services/purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class UserViewModel extends ChangeNotifier {
  final _purchaseService = PurchaseService();
  final _iapService = IapService();
  late StreamSubscription<PurchaseDetails> _purchaseSubscription;

  bool _isPremium = false;
  bool _isLoading = true;

  List<ProductDetails> _products = [];

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  List<ProductDetails> get products => _products;

  UserViewModel() {
    loadUserStatus();
    _listenToPurchases();
  }

  Future<void> loadUserStatus() async {
    _isLoading = true;
    notifyListeners();
    _isPremium = await _purchaseService.isPremiumUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _products = await _iapService.getProducts();
    notifyListeners();
  }

  void _listenToPurchases() {
    _purchaseSubscription = _iapService.purchaseStream.listen((purchaseDetails) {
      // 구매가 성공하면 프리미엄 상태로 전환
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        upgradeToPremium();
      }
    });
  }

  void buy(ProductDetails product) {
    _iapService.buyProduct(product);
  }

  void restorePurchases() {
    _iapService.restorePurchases();
  }

  Future<void> upgradeToPremium() async {
    if (_isPremium) return;
    _isPremium = true;
    await _purchaseService.savePremiumStatus(true);
    notifyListeners();
  }

  Future<void> revertToFree() async {
    _isPremium = false;
    await _purchaseService.savePremiumStatus(false);
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSubscription.cancel();
    _iapService.dispose();
    super.dispose();
  }
}