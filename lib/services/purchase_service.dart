import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService {
  static const _isPremiumUserKey = 'is_premium_user';

  // 사용자의 프리미엄 상태를 불러옴
  Future<bool> isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    // 저장된 값이 없으면 기본값 false 반환
    return prefs.getBool(_isPremiumUserKey) ?? false;
  }

  // 사용자의 프리미엄 상태를 저장
  Future<void> savePremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumUserKey, isPremium);
  }
}