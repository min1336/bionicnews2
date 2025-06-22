import 'package:focus_news/services/read_article_service.dart';
import 'package:flutter/material.dart';
import 'package:focus_news/models/news_article.dart';
import 'package:focus_news/services/news_api_service.dart';

enum NotifierState { initial, loading, loadingMore, loaded, error }

class NewsViewModel extends ChangeNotifier {
  final _newsApiService = NewsApiService();
  final _readArticleService = ReadArticleService();

  List<NewsArticle> articles = [];
  NotifierState state = NotifierState.initial;
  String errorMessage = '';

  bool _hasMore = true;
  int _start = 1;
  String? currentQuery;
  static const int _display = 100;

  Future<void> fetchNews(String query, {bool isRefresh = false}) async {
    if (isRefresh) {
      debugPrint("[NewsViewModel] Refreshing data for query: '$query'");
      articles.clear();
      _start = 1;
      _hasMore = true;
      currentQuery = query;
      state = NotifierState.loading;
      notifyListeners();
    } else {
      if (state == NotifierState.loading ||
          state == NotifierState.loadingMore ||
          !_hasMore) {
        return;
      }
      state = NotifierState.loadingMore;
      notifyListeners();
    }

    debugPrint(
        "[NewsViewModel] Fetching news for '$query'. Start: $_start, HasMore: $_hasMore");

    try {
      if (_start > 1000) {
        _hasMore = false;
        state = NotifierState.loaded;
        notifyListeners();
        return;
      }

      final newArticles =
      await _newsApiService.fetchNews(query, start: _start, display: _display);

      if (newArticles.isEmpty) {
        _hasMore = false;
        debugPrint("[NewsViewModel] Reached end of results for '$query'.");
      }

      final readLinks = await _readArticleService.getReadArticles();
      for (var article in newArticles) {
        if (readLinks.contains(article.articleUrl)) {
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

    notifyListeners();
  }

  void markArticleAsRead(NewsArticle article) {
    final index =
    articles.indexWhere((a) => a.articleUrl == article.articleUrl);
    if (index != -1 && !articles[index].isRead) {
      articles[index].isRead = true;
      notifyListeners();
    }
  }
}