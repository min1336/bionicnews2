import 'package:focus_news/models/news_article.dart';
import 'package:focus_news/services/bookmark_service.dart';
import 'package:flutter/material.dart';

class BookmarkViewModel extends ChangeNotifier {
  final _bookmarkService = BookmarkService();
  List<NewsArticle> _bookmarks = [];
  bool _isLoading = true;

  List<NewsArticle> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;

  BookmarkViewModel() {
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    _isLoading = true;
    notifyListeners();

    _bookmarks = await _bookmarkService.getBookmarks();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBookmark(NewsArticle article) async {
    // UI에 즉시 반영
    _bookmarks.add(article);
    notifyListeners();
    // 서비스에 저장
    await _bookmarkService.addBookmark(article);
  }

  Future<void> removeBookmark(NewsArticle article) async {
    // UI에 즉시 반영
    _bookmarks.removeWhere((item) => item.content == article.content);
    notifyListeners();
    // 서비스에서 삭제
    await _bookmarkService.removeBookmark(article);
  }

  bool isBookmarked(NewsArticle article) {
    return _bookmarks.any((item) => item.content == article.content);
  }
}