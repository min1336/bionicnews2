import 'package:bionic_news/services/read_article_service.dart';
import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../services/news_api_service.dart';

enum NotifierState { initial, loading, loadingMore, loaded, error }

class NewsViewModel extends ChangeNotifier {
  final _newsApiService = NewsApiService();
  final _readArticleService = ReadArticleService(); // 읽기 서비스 인스턴스 추가

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
      debugPrint("[NewsViewModel] Refreshing data for query: '$query'");
      articles.clear();
      _start = 1;
      _hasMore = true;
      currentQuery = query;
      state = NotifierState.loading;
      notifyListeners();
    } else {
      if (state == NotifierState.loading || state == NotifierState.loadingMore || !_hasMore) {
        return;
      }
      state = NotifierState.loadingMore;
      notifyListeners();
    }

    debugPrint("[NewsViewModel] Fetching news for '$query'. Start: $_start, HasMore: $_hasMore");

    // 2. API 호출
    try {
      if (_start > 1000) {
        _hasMore = false;
        state = NotifierState.loaded;
        notifyListeners();
        return;
      }

      final newArticles = await _newsApiService.fetchNews(query, start: _start, display: _display);

      // 3. 상태 업데이트
      // ★★★ 여기가 수정된 부분입니다 ★★★
      // 불러온 기사 리스트가 '비어있을 때'만 마지막 페이지로 간주합니다.
      if (newArticles.isEmpty) {
        _hasMore = false;
        debugPrint("[NewsViewModel] Reached end of results for '$query'.");
      }

      final readLinks = await _readArticleService.getReadArticles();
      for (var article in newArticles) {
        if (readLinks.contains(article.content)) {
          article.isRead = true;
        }
      }

      articles.addAll(newArticles);
      _start += _display;
      state = NotifierState.loaded;

    } catch (e) {
      debugPrint("[NewsViewModel] Error fetching news: $e");
      state = NotifierState.error;
      errorMessage = e.toString();
    }

    // 4. UI 갱신
    notifyListeners();
  }

  /// 특정 기사를 '읽음'으로 표시하고 UI를 갱신하는 함수
  void markArticleAsRead(NewsArticle article) {
    final index = articles.indexWhere((a) => a.content == article.content);
    if (index != -1 && !articles[index].isRead) {
      articles[index].isRead = true;
      notifyListeners();
    }
  }
}