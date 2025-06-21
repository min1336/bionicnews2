import 'dart:async';
import 'package:bionic_news/services/news_scraper_service.dart';
import 'package:flutter/material.dart';

class ReaderViewModel extends ChangeNotifier {
  final _scraperService = NewsScraperService();

  // State
  List<String> _words = [];
  int _currentIndex = 0;
  bool _isPlaying = true;
  int _wpm = 450;
  bool _isFinished = false;
  bool _isLoading = true;
  String _articleContent = '';
  String _errorMessage = '';

  Timer? _timer;

  // Getters for UI
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  bool get isFinished => _isFinished;
  String get currentWord => _isLoading || _words.isEmpty ? '' : _words[_currentIndex];
  double get progress => _isLoading || _words.isEmpty ? 0.0 : (_currentIndex + 1) / _words.length;
  int get wordCount => _words.length;
  int get currentWordIndex => _currentIndex + 1;
  int get wpm => _wpm;
  String get errorMessage => _errorMessage;

  ReaderViewModel(String articleUrl) {
    loadArticleContent(articleUrl);
  }

  Future<void> loadArticleContent(String url, {bool isRestart = false}) async {
    _isLoading = true;
    if(isRestart) {
      _currentIndex = 0;
    }
    notifyListeners();

    try {
      final content = await _scraperService.scrapeArticleContent(url);
      _articleContent = content;
      _words = _articleContent.split(RegExp(r'\\s+')).where((s) => s.isNotEmpty).toList();
      _errorMessage = '';

      if (_words.isNotEmpty) {
        _isFinished = false;
        _isPlaying = true;
        _startTimer();
      } else {
        _errorMessage = '기사 본문을 불러올 수 없거나 내용이 없습니다.';
        _isFinished = true;
        _isPlaying = false;
      }
    } catch (e) {
      _errorMessage = '기사 본문을 불러오는 중 오류가 발생했습니다.';
      _isFinished = true;
      _isPlaying = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_words.isEmpty) return;

    final duration = Duration(milliseconds: (60000 / _wpm).round());
    _timer = Timer.periodic(duration, (timer) {
      if (_isPlaying && _currentIndex < _words.length - 1) {
        _currentIndex++;
        notifyListeners();
      } else {
        _timer?.cancel();
        _isPlaying = false;
        _isFinished = true;
        notifyListeners();
      }
    });
  }

  void togglePlayPause() {
    if (_isFinished || _isLoading) return;
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
    notifyListeners();
  }

  void changeSpeed(int amount) {
    _wpm = (_wpm + amount).clamp(60, 1200); // WPM 범위 조정
    if (_isPlaying) {
      _startTimer();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}