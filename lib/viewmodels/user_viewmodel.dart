import 'package:focus_news/services/purchase_service.dart';
import 'package:flutter/material.dart';

class UserViewModel extends ChangeNotifier {
  final _purchaseService = PurchaseService();

  bool _isPremium = false;
  bool _isLoading = true;

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;

  UserViewModel() {
    loadUserStatus();
  }

  Future<void> loadUserStatus() async {
    _isLoading = true;
    notifyListeners();

    _isPremium = await _purchaseService.isPremiumUser();

    _isLoading = false;
    notifyListeners();
  }

  // 프리미엄으로 업그레이드하는 함수 (실제 결제 로직은 추후 추가)
  Future<void> upgradeToPremium() async {
    _isPremium = true;
    await _purchaseService.savePremiumStatus(true);
    notifyListeners();
  }

  // 무료 버전으로 되돌리는 함수 (테스트용)
  Future<void> revertToFree() async {
    _isPremium = false;
    await _purchaseService.savePremiumStatus(false);
    notifyListeners();
  }
}