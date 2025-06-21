import 'package:shared_preferences/shared_preferences.dart';

class ReadArticleService {
  static const _readArticlesKey = 'read_articles';

  // 읽은 기사 목록(Set) 불러오기
  Future<Set<String>> getReadArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_readArticlesKey) ?? [];
    return list.toSet(); // 빠른 조회를 위해 Set으로 변환
  }

  // 읽은 기사 목록에 새로운 링크 추가
  Future<void> addReadArticle(String link) async {
    if (link.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    Set<String> readArticles = await getReadArticles();

    // 이미 있다면 추가하지 않음
    if (readArticles.add(link)) {
      // Set에 성공적으로 추가되었을 때만 저장소에 씀
      await prefs.setStringList(_readArticlesKey, readArticles.toList());
    }
  }
}