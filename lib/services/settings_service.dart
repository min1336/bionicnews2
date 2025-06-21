import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _wpmKey = 'settings_wpm';
  static const _ratioKey = 'settings_saccade_ratio';
  static const _emphasisColorKey = 'settings_emphasis_color';
  static const _themeColorKey = 'settings_theme_color';
  // ★★★ 여기가 추가된 부분입니다 ★★★
  static const _themeModeKey = 'settings_theme_mode';

  Future<void> saveWpm(int wpm) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_wpmKey, wpm);
  }

  Future<int> getWpm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_wpmKey) ?? 450;
  }

  Future<void> saveSaccadeRatio(double ratio) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_ratioKey, ratio);
  }

  Future<double> getSaccadeRatio() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_ratioKey) ?? 0.5;
  }

  Future<void> saveEmphasisColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_emphasisColorKey, color.value);
  }

  Future<Color> getEmphasisColor() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_emphasisColorKey);
    return value != null ? Color(value) : Colors.red;
  }

  Future<void> saveThemeColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeColorKey, color.value);
  }

  Future<Color> getThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_themeColorKey);
    return value != null ? Color(value) : Colors.blueGrey;
  }

  // ★★★ 여기가 추가된 부분입니다 ★★★
  Future<void> saveThemeMode(String themeModeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeModeName);
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    // 기본값 'system'
    return prefs.getString(_themeModeKey) ?? 'system';
  }
}