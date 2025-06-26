import 'package:shared_preferences/shared_preferences.dart';

class ReadArticleService {
  static const _readArticlesKey = 'read_articles';

  Future<Set<String>> getReadArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_readArticlesKey) ?? [];
    return list.toSet();
  }

  Future<void> addReadArticle(String link) async {
    if (link.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    Set<String> readArticles = await getReadArticles();

    if (readArticles.add(link)) {
      await prefs.setStringList(_readArticlesKey, readArticles.toList());
    }
  }

  // ★★★ 여기가 추가된 부분입니다 ★★★
  Future<void> clearReadArticles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_readArticlesKey);
  }
}