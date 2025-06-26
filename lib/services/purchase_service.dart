import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService {
  static const _isPremiumUserKey = 'is_premium_user';

  Future<bool> isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isPremiumUserKey) ?? false;
  }

  Future<void> savePremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumUserKey, isPremium);
  }

  // ★★★ 여기가 추가된 부분입니다 ★★★
  Future<void> clearPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isPremiumUserKey);
  }
}