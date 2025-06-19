import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const _historyKey = 'search_history';

  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  Future<void> addSearchTerm(String term) async {
    if (term.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> history = await getSearchHistory();

    history.remove(term);
    history.insert(0, term);

    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    await prefs.setStringList(_historyKey, history);
  }

  Future<void> removeSearchTerm(String term) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = await getSearchHistory();
    history.remove(term);
    await prefs.setStringList(_historyKey, history);
  }

  // ★★★ 여기가 추가된 부분입니다 ★★★
  // 전체 검색 기록을 삭제하는 함수
  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}