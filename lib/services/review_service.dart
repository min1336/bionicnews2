import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  final InAppReview _inAppReview = InAppReview.instance;

  static const _reviewTriggerCountKey = 'review_trigger_count';
  static const _hasRequestedReviewKey = 'has_requested_review';
  static const int _reviewTriggerThreshold = 3; // 3번째 북마크 시 요청

  Future<void> requestReviewIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final bool hasAlreadyRequested =
          prefs.getBool(_hasRequestedReviewKey) ?? false;
      if (hasAlreadyRequested) {
        debugPrint('[ReviewService] 이미 리뷰를 요청했으므로 건너뜁니다.');
        return;
      }

      int currentCount = prefs.getInt(_reviewTriggerCountKey) ?? 0;
      currentCount++;
      await prefs.setInt(_reviewTriggerCountKey, currentCount);
      debugPrint('[ReviewService] 북마크 카운트: $currentCount');

      // ★★★ 여기가 수정된 부분입니다: '=='를 '>='로 변경 ★★★
      if (currentCount >= _reviewTriggerThreshold) {
        debugPrint('[ReviewService] 리뷰 요청 조건 충족. OS에 리뷰를 요청합니다.');
        if (await _inAppReview.isAvailable()) {
          _inAppReview.requestReview();
          await prefs.setBool(_hasRequestedReviewKey, true);
          debugPrint('[ReviewService] 리뷰 요청 완료. 앞으로 요청하지 않습니다.');
        } else {
          debugPrint('[ReviewService] 스토어 리뷰를 사용할 수 없는 환경입니다.');
          // 이 경우에도 다시 요청하지 않도록 플래그를 저장할 수 있습니다.
          await prefs.setBool(_hasRequestedReviewKey, true);
        }
      } else {
        debugPrint(
            '[ReviewService] 아직 리뷰 요청 조건에 도달하지 않았습니다. (${_reviewTriggerThreshold - currentCount}번 남음)');
      }
    } catch (e) {
      debugPrint('[ReviewService] 리뷰 요청 중 오류 발생: $e');
    }
  }
}