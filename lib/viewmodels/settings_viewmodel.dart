import 'package:focus_news/services/settings_service.dart';
import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  final _settingsService = SettingsService();

  int _wpm = 450;
  double _saccadeRatio = 0.5;
  Color _emphasisColor = Colors.red;
  Color _themeColor = Colors.blueGrey;
  // ★★★ 여기가 추가된 부분입니다 ★★★
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;

  int get wpm => _wpm;
  double get saccadeRatio => _saccadeRatio;
  Color get emphasisColor => _emphasisColor;
  Color get themeColor => _themeColor;
  // ★★★ 여기가 추가된 부분입니다 ★★★
  ThemeMode get themeMode => _themeMode;
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
    // ★★★ 여기가 추가된 부분입니다 ★★★
    final themeModeName = await _settingsService.getThemeMode();
    _themeMode = ThemeMode.values.firstWhere(
          (e) => e.name == themeModeName,
      orElse: () => ThemeMode.system,
    );

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

  // ★★★ 여기가 추가된 부분입니다 ★★★
  Future<void> updateThemeMode(ThemeMode newThemeMode) async {
    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.saveThemeMode(newThemeMode.name);
  }
}