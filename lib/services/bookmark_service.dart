import 'dart:convert';
import 'package:focus_news/models/news_article.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const _bookmarkKey = 'bookmarked_articles';

  Future<List<NewsArticle>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookmarksJson = prefs.getStringList(_bookmarkKey) ?? [];

    return bookmarksJson
        .map((jsonString) => NewsArticle.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  Future<void> _saveBookmarks(List<NewsArticle> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookmarksJson =
    bookmarks.map((article) => jsonEncode(article.toJson())).toList();
    await prefs.setStringList(_bookmarkKey, bookmarksJson);
  }

  Future<void> addBookmark(NewsArticle article) async {
    final List<NewsArticle> bookmarks = await getBookmarks();
    // 중복 추가 방지 (기사 링크를 고유 ID로 사용)
    if (!bookmarks.any((item) => item.content == article.content)) {
      bookmarks.add(article);
      await _saveBookmarks(bookmarks);
    }
  }

  Future<void> removeBookmark(NewsArticle article) async {
    List<NewsArticle> bookmarks = await getBookmarks();
    bookmarks.removeWhere((item) => item.content == article.content);
    await _saveBookmarks(bookmarks);
  }
}