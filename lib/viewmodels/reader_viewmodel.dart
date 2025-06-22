import 'dart:async';
import 'package:focus_news/main.dart';
import 'package:focus_news/services/news_scraper_service.dart';
import 'package:flutter/material.dart';
import 'package:focus_news/services/ad_service.dart';

class ReaderViewModel extends ChangeNotifier {
  final _scraperService = NewsScraperService();
  final AdService adService;

  List<String> _words = [];
  int _currentIndex = 0;
  bool _isPlaying = true;
  late int _wpm;
  late double _saccadeRatio;
  late Color _emphasisColor;
  bool _isFinished = false;
  bool _isLoading = true;
  String _articleContent = '';
  String _errorMessage = '';

  Timer? _timer;

  final Function(int) onWpmChanged;
  final Function(double) onSaccadeRatioChanged;
  final bool isPremiumUser;

  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  bool get isFinished => _isFinished;
  String get currentWord =>
      _isLoading || _words.isEmpty ? '' : _words[_currentIndex];
  double get progress =>
      _isLoading || _words.isEmpty ? 0.0 : (_currentIndex + 1) / _words.length;
  int get wordCount => _words.length;
  int get currentWordIndex => _currentIndex + 1;
  int get wpm => _wpm;
  double get saccadeRatio => _saccadeRatio;
  Color get emphasisColor => _emphasisColor;
  String get errorMessage => _errorMessage;

  ReaderViewModel({
    required String articleUrl,
    required int initialWpm,
    required double initialSaccadeRatio,
    required Color initialEmphasisColor,
    required this.onWpmChanged,
    required this.onSaccadeRatioChanged,
    required this.isPremiumUser,
    required this.adService,
  }) {
    _wpm = initialWpm;
    _saccadeRatio = initialSaccadeRatio;
    _emphasisColor = initialEmphasisColor;
    loadArticleContent(articleUrl);
  }

  Future<void> loadArticleContent(String url, {bool isRestart = false}) async {
    _isLoading = true;
    if (isRestart) {
      _currentIndex = 0;
      _errorMessage = '';
    }
    notifyListeners();

    try {
      final content = await _scraperService.scrapeArticleContent(url);

      if (content == NewsScraperService.parsingFailedError ||
          content == NewsScraperService.requestFailedError ||
          content == NewsScraperService.exceptionError) {
        _errorMessage = '기사 본문을 불러오는 데 실패했습니다.';
        _isFinished = true;
        _isPlaying = false;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _articleContent = content;
      _words =
          _articleContent.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
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
    final newWpm = (_wpm + amount).clamp(100, 1200);
    _wpm = newWpm;
    onWpmChanged(_wpm);

    if (_isPlaying) {
      _startTimer();
    }
    notifyListeners();
  }

  void changeSaccadeRatio(double newRatio) {
    _saccadeRatio = newRatio.clamp(0.2, 0.8);
    onSaccadeRatioChanged(_saccadeRatio);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    adService.showInterstitialAdIfNeeded(isPremium: isPremiumUser);
    super.dispose();
  }
}