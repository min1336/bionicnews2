import 'package:shared_preferences/shared_preferences.dart';

class TopicService {
  static const _userTopicsKey = 'user_selected_topics';

  // 앱에서 선택 가능한 전체 주제 목록
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

  // 처음 앱을 실행하는 사용자를 위한 기본 주제 목록
  static const List<String> _defaultTopics = [
    'IT/과학',
    '경제',
    '생활/문화',
    '정치',
    '세계',
    '스포츠',
  ];

  // 사용자의 관심 주제 목록을 불러옴
  Future<List<String>> getUserTopics() async {
    final prefs = await SharedPreferences.getInstance();
    // 저장된 목록이 없으면(최초 실행 시) 기본 목록을 반환
    return prefs.getStringList(_userTopicsKey) ?? _defaultTopics;
  }

  // 사용자의 관심 주제 목록을 저장
  Future<void> saveUserTopics(List<String> topics) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_userTopicsKey, topics);
  }
}