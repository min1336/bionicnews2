import 'package:focus_news/services/bookmark_service.dart';
import 'package:focus_news/services/purchase_service.dart';
import 'package:focus_news/services/read_article_service.dart';
import 'package:focus_news/services/review_service.dart';
import 'package:focus_news/services/search_history_service.dart';
import 'package:focus_news/services/settings_service.dart';
import 'package:focus_news/services/topic_service.dart';
import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  final _settingsService = SettingsService();

  int _wpm = 450;
  double _saccadeRatio = 0.5;
  Color _emphasisColor = Colors.red;
  Color _themeColor = Colors.blueGrey;
  ThemeMode _themeMode = ThemeMode.system;
  String _fontFamily = 'Noto Sans KR';
  bool _isLoading = true;

  int get wpm => _wpm;
  double get saccadeRatio => _saccadeRatio;
  Color get emphasisColor => _emphasisColor;
  Color get themeColor => _themeColor;
  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;
  bool get isLoading => _isLoading;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    _wpm = await _settingsService.getWpm();
    _saccadeRatio = await _settingsService.getSaccadeRatio();
    _emphasisColor = await _settingsService.getEmphasisColor();
    _themeColor = await _settingsService.getThemeColor();
    final themeModeName = await _settingsService.getThemeMode();
    _themeMode = ThemeMode.values.firstWhere(
          (e) => e.name == themeModeName,
      orElse: () => ThemeMode.system,
    );
    _fontFamily = await _settingsService.getFontFamily();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateWpm(int newWpm) async {
    _wpm = newWpm;
    notifyListeners();
    await _settingsService.saveWpm(_wpm);
  }

  Future<void> updateSaccadeRatio(double newRatio) async {
    _saccadeRatio = newRatio;
    notifyListeners();
    await _settingsService.saveSaccadeRatio(_saccadeRatio);
  }

  Future<void> updateEmphasisColor(Color newColor) async {
    _emphasisColor = newColor;
    notifyListeners();
    await _settingsService.saveEmphasisColor(_emphasisColor);
  }

  Future<void> updateThemeColor(Color newColor) async {
    _themeColor = newColor;
    notifyListeners();
    await _settingsService.saveThemeColor(_themeColor);
  }

  Future<void> updateThemeMode(ThemeMode newThemeMode) async {
    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.saveThemeMode(newThemeMode.name);
  }

  Future<void> updateFontFamily(String newFontFamily) async {
    _fontFamily = newFontFamily;
    notifyListeners();
    await _settingsService.saveFontFamily(newFontFamily);
  }

  Future<void> resetAllApplicationData() async {
    await _settingsService.resetAllSettings();
    await BookmarkService().clearBookmarks();
    await ReadArticleService().clearReadArticles();
    await ReviewService().resetReviewRequest();
    await SearchHistoryService().clearSearchHistory();
    await TopicService().clearUserTopics();
    await PurchaseService().clearPremiumStatus();

    // 설정값을 다시 불러와서 UI에 즉시 반영
    await _loadSettings();
  }
}