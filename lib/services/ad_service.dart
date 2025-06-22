import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const _interstitialTriggerCountKey = 'interstitial_trigger_count';
  static const int _interstitialTriggerThreshold = 3;

  InterstitialAd? _interstitialAd;
  bool _isShowingAd = false;

  void createAndLoadInterstitialAd() {
    if (_interstitialAd != null) {
      return;
    }
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('[AdService] 전면 광고 미리 로딩 성공: $ad');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('[AdService] 전면 광고 미리 로딩 실패: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  Future<void> showInterstitialAdIfNeeded({required bool isPremium}) async {
    if (isPremium) {
      debugPrint('[AdService] 프리미엄 사용자이므로 전면 광고를 표시하지 않습니다.');
      return;
    }
    if (_isShowingAd) {
      debugPrint('[AdService] 이미 다른 광고가 표시 중입니다.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt(_interstitialTriggerCountKey) ?? 0;
    currentCount++;
    await prefs.setInt(_interstitialTriggerCountKey, currentCount);
    debugPrint('[AdService] 전면 광고 트리거 카운트: $currentCount');

    if (currentCount >= _interstitialTriggerThreshold) {
      debugPrint('[AdService] 전면 광고 표시 조건 충족.');
      if (_interstitialAd != null) {
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (InterstitialAd ad) {
            _isShowingAd = true;
            debugPrint('[AdService] 전면 광고가 화면에 표시됨.');
          },
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
            debugPrint('[AdService] 전면 광고가 닫힘.');
            ad.dispose();
            _isShowingAd = false;
            _interstitialAd = null;
            createAndLoadInterstitialAd();
          },
          onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
            debugPrint('[AdService] 전면 광고 표시에 실패: $error');
            ad.dispose();
            _isShowingAd = false;
            _interstitialAd = null;
            createAndLoadInterstitialAd();
          },
        );

        await _interstitialAd!.show();
        await prefs.setInt(_interstitialTriggerCountKey, 0);
      } else {
        debugPrint('[AdService] 미리 로드된 전면 광고가 없습니다. 다음 광고를 로드합니다.');
        createAndLoadInterstitialAd();
      }
    }
  }
}