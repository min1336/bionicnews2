import 'package:focus_news/models/news_article.dart';
import 'package:focus_news/services/bookmark_service.dart';
import 'package:focus_news/services/review_service.dart';
import 'package:flutter/material.dart';

class BookmarkViewModel extends ChangeNotifier {
  final _bookmarkService = BookmarkService();
  // ★★★ 여기가 추가된 부분입니다 ★★★
  final _reviewService = ReviewService();

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
    _bookmarks.add(article);
    notifyListeners();
    await _bookmarkService.addBookmark(article);
    // ★★★ 여기가 추가된 부분입니다: 북마크 추가 후 리뷰 요청 조건 확인 ★★★
    await _reviewService.requestReviewIfNeeded();
  }

  Future<void> removeBookmark(NewsArticle article) async {
    _bookmarks.removeWhere((item) => item.articleUrl == article.articleUrl);
    notifyListeners();
    await _bookmarkService.removeBookmark(article);
  }

  bool isBookmarked(NewsArticle article) {
    return _bookmarks.any((item) => item.articleUrl == article.articleUrl);
  }
}