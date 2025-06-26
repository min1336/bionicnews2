import 'package:shared_preferences/shared_preferences.dart';

class TopicService {
  static const _userTopicsKey = 'user_selected_topics';

  static const List<String> allAvailableTopics = [
    'IT/과학',
    '경제',
    '생활/문화',
    '정치',
    '세계',
    '스포츠',
    '연예',
    '사회',
  ];

  static const List<String> _defaultTopics = [
    'IT/과학',
    '경제',
    '생활/문화',
    '정치',
    '세계',
    '스포츠',
  ];

  Future<List<String>> getUserTopics() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_userTopicsKey) ?? _defaultTopics;
  }

  Future<void> saveUserTopics(List<String> topics) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_userTopicsKey, topics);
  }

  // ★★★ 여기가 추가된 부분입니다 ★★★
  Future<void> clearUserTopics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userTopicsKey);
  }
}