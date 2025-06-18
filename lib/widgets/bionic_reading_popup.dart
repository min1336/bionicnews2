import 'dart:async';
import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../services/bionic_reading_service.dart';
import '../services/news_scraper_service.dart'; // 스크래퍼 서비스 import

class BionicReadingPopup extends StatefulWidget {
  final NewsArticle article;

  const BionicReadingPopup({super.key, required this.article});

  @override
  State<BionicReadingPopup> createState() => _BionicReadingPopupState();
}

class _BionicReadingPopupState extends State<BionicReadingPopup> {
  late List<String> _words;
  int _currentIndex = 0;
  Timer? _timer;
  bool _isPlaying = true;
  int _wpm = 450;
  bool _isFinished = false;
  String _articleContent = '';
  bool _isLoading = true;
  final _scraperService = NewsScraperService();

  @override
  void initState() {
    super.initState();
    _words = []; // 초기화
    _loadArticleContent();
  }

  Future<void> _loadArticleContent() async {
    setState(() {
      _isLoading = true;
      _isFinished = false;
      _isPlaying = true;
    });
    // 네이버 뉴스 링크는 content 필드에 저장해두었습니다.
    final content = await _scraperService.scrapeArticleContent(widget.article.content);
    setState(() {
      _articleContent = content;
      _words = _articleContent.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
      _currentIndex = 0;
      _isLoading = false;
      if (_words.isNotEmpty) {
        _startTimer();
      } else {
        _isPlaying = false;
        _isFinished = true;
        _articleContent = '본문 내용을 불러올 수 없습니다.';
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    final duration = Duration(milliseconds: (60000 / _wpm).round());
    _timer = Timer.periodic(duration, (timer) {
      if (_isPlaying && _currentIndex < _words.length - 1) {
        setState(() {
          _currentIndex++;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isPlaying = false;
          _isFinished = true;
        });
      }
    });
  }

  void _restart() {
    setState(() {
      // 스크래핑을 다시 하지 않고, 인덱스와 상태만 초기화
      _currentIndex = 0;
      _isFinished = false;
      _isPlaying = true;
      // 타이머만 다시 시작
      _startTimer();
    });
  }

  void _togglePlayPause() {
    if (_isFinished || _isLoading) return;

    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _changeSpeed(int amount) {
    setState(() {
      _wpm = (_wpm + amount).clamp(60, 900);
      if (_isPlaying) {
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = _isLoading || _words.isEmpty ? '' : _words[_currentIndex];
    final progress = _isLoading || _words.isEmpty ? 0.0 : (_currentIndex + 1) / _words.length;

    return AlertDialog(
      title: Text(widget.article.title, style: const TextStyle(fontSize: 18), maxLines: 2, overflow: TextOverflow.ellipsis,),
      content: SizedBox(
        height: 150, // 높이 조절
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _words.isEmpty
            ? const Center(child: Text('본문을 가져올 수 없습니다.'))
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                // ★★★ 여기가 수정된 부분입니다 ★★★
                child: Center(
                  child: BionicReadingService.getBionicText(
                    currentWord,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blueGrey,
            ),
            Text('${_words.isEmpty ? 0 : _currentIndex + 1} / ${_words.length}'),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          tooltip: '느리게',
          onPressed: () => _changeSpeed(-50),
        ),
        if (_isFinished)
          IconButton(
            icon: const Icon(Icons.replay_circle_filled_outlined, size: 40, color: Colors.blueGrey),
            tooltip: '재시작',
            onPressed: _restart,
          )
        else
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 40),
            tooltip: _isPlaying ? '일시정지' : '재생',
            onPressed: _togglePlayPause,
          ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: '빠르게',
          onPressed: () => _changeSpeed(50),
        ),
      ],
    );
  }
}