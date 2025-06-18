import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../services/news_api_service.dart';

enum NotifierState { initial, loading, loaded, error }

class NewsViewModel extends ChangeNotifier {
  final _newsApiService = NewsApiService();

  List<NewsArticle> _articles = [];
  List<NewsArticle> get articles => _articles;

  NotifierState _state = NotifierState.initial;
  NotifierState get state => _state;

  Future<void> fetchNews(String query) async {
    _state = NotifierState.loading;
    notifyListeners(); // UI에게 로딩 시작을 알림

    try {
      _articles = await _newsApiService.fetchNews(query);
      _state = NotifierState.loaded;
    } catch (e) {
      print(e);
      _state = NotifierState.error;
    }

    notifyListeners(); // UI에게 로딩 완료 또는 에러 상태를 알림
  }
}