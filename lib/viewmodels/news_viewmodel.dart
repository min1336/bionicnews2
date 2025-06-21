import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../services/news_api_service.dart';

enum NotifierState { initial, loading, loadingMore, loaded, error }

class NewsViewModel extends ChangeNotifier {
  final _newsApiService = NewsApiService();

  List<NewsArticle> articles = [];
  NotifierState state = NotifierState.initial;
  String errorMessage = '';

  bool _hasMore = true;
  int _start = 1;
  String? currentQuery;
  static const int _display = 100;

  /// 뉴스를 불러오는 통합 함수. 새로고침과 더 불러오기 기능을 모두 담당합니다.
  Future<void> fetchNews(String query, {bool isRefresh = false}) async {
    // 1. 상태 확인 및 초기화
    if (isRefresh) {
      // 새로고침 요청 시, 모든 상태를 초기화합니다.
      // 이는 과거 코드의 `_loadInitialNews`와 유사한 역할입니다.
      debugPrint("[NewsViewModel] Refreshing data for query: '$query'");
      articles.clear();
      _start = 1;
      _hasMore = true;
      currentQuery = query;
      state = NotifierState.loading;
      notifyListeners();
    } else {
      // 더 불러오기 요청 시, 이미 로딩 중이거나 더 이상 데이터가 없으면 중복 실행을 방지합니다.
      // 이는 과거 코드의 `if (_isLoadingMore || !_hasMore) return;` 부분에 해당합니다.
      if (state == NotifierState.loading || state == NotifierState.loadingMore || !_hasMore) {
        return;
      }
      // '더 불러오기' 시작을 UI에 알립니다.
      state = NotifierState.loadingMore;
      notifyListeners();
    }

    debugPrint("[NewsViewModel] Fetching news for '$query'. Start: $_start, HasMore: $_hasMore");

    // 2. API 호출
    try {
      // 네이버 API는 start 파라미터가 1000을 초과하면 에러를 반환하므로 이를 방지합니다.
      if (_start > 1000) {
        _hasMore = false;
        state = NotifierState.loaded;
        notifyListeners();
        return;
      }

      final newArticles = await _newsApiService.fetchNews(query, start: _start, display: _display);

      // 3. 상태 업데이트
      // 불러온 데이터가 요청한 개수보다 적으면, 마지막 페이지로 간주합니다.
      if (newArticles.length < _display) {
        _hasMore = false;
        debugPrint("[NewsViewModel] Reached end of results for '$query'.");
      }

      articles.addAll(newArticles);
      _start += _display; // 다음 요청을 위해 시작 인덱스를 증가시킵니다.
      state = NotifierState.loaded;

    } catch (e) {
      debugPrint("[NewsViewModel] Error fetching news: $e");
      state = NotifierState.error;
      errorMessage = e.toString();
    }

    // 4. UI 갱신
    notifyListeners();
  }
}