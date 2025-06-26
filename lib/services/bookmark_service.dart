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
    if (!bookmarks.any((item) => item.articleUrl == article.articleUrl)) {
      bookmarks.add(article);
      await _saveBookmarks(bookmarks);
    }
  }

  Future<void> removeBookmark(NewsArticle article) async {
    List<NewsArticle> bookmarks = await getBookmarks();
    bookmarks.removeWhere((item) => item.articleUrl == article.articleUrl);
    await _saveBookmarks(bookmarks);
  }

  // ★★★ 여기가 추가된 부분입니다 ★★★
  Future<void> clearBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bookmarkKey);
  }
}