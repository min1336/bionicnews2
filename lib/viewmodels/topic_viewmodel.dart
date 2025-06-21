import 'package:focus_news/services/topic_service.dart';
import 'package:flutter/material.dart';

class TopicViewModel extends ChangeNotifier {
  final _topicService = TopicService();

  List<String> _userTopics = [];
  bool _isLoading = true;

  List<String> get userTopics => _userTopics;
  List<String> get allAvailableTopics => TopicService.allAvailableTopics;
  bool get isLoading => _isLoading;

  TopicViewModel() {
    loadTopics();
  }

  Future<void> loadTopics() async {
    _isLoading = true;
    notifyListeners();

    final topics = await _topicService.getUserTopics();
    // ★★★ 여기가 수정된 부분입니다 ★★★
    // 서비스로부터 받은 리스트를 수정 가능한 새 리스트로 복사합니다.
    _userTopics = List<String>.from(topics);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTopic(String topic) async {
    if (!_userTopics.contains(topic)) {
      _userTopics.add(topic);
      await _topicService.saveUserTopics(_userTopics);
      notifyListeners();
    }
  }

  Future<void> removeTopic(String topic) async {
    _userTopics.remove(topic);
    await _topicService.saveUserTopics(_userTopics);
    notifyListeners();
  }

  Future<void> reorderTopics(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = _userTopics.removeAt(oldIndex);
    _userTopics.insert(newIndex, item);

    await _topicService.saveUserTopics(_userTopics);
    notifyListeners();
  }
}