import 'package:focus_news/models/news_article.dart';
import 'package:focus_news/services/bookmark_service.dart';
import 'package:focus_news/services/review_service.dart';
import 'package:flutter/material.dart';

class BookmarkViewModel extends ChangeNotifier {
  final _bookmarkService = BookmarkService();
  final _reviewService = ReviewService();

  List<NewsArticle> _bookmarks = [];
  bool _isLoading = true;
  // ★★★ 여기가 추가된 부분입니다: 오류 상태 변수 ★★★
  bool _hasError = false;
  String _errorMessage = '';

  List<NewsArticle> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  // ★★★ 여기가 추가된 부분입니다: 오류 상태 Getter ★★★
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  BookmarkViewModel() {
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    _isLoading = true;
    // ★★★ 여기가 추가된 부분입니다: 오류 상태 초기화 ★★★
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      _bookmarks = await _bookmarkService.getBookmarks();
    } catch (e) {
      // ★★★ 여기가 추가된 부분입니다: 오류 발생 시 상태 변경 ★★★
      _hasError = true;
      _errorMessage = e.toString();
      debugPrint('[BookmarkViewModel] 북마크 로딩 중 오류 발생: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBookmark(NewsArticle article) async {
    _bookmarks.add(article);
    notifyListeners();
    await _bookmarkService.addBookmark(article);
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