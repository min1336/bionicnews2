import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _wpmKey = 'settings_wpm';
  static const _ratioKey = 'settings_saccade_ratio';
  static const _emphasisColorKey = 'settings_emphasis_color';
  static const _themeColorKey = 'settings_theme_color';
  static const _themeModeKey = 'settings_theme_mode';
  static const _fontFamilyKey = 'settings_font_family';

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

  Future<void> saveThemeMode(String themeModeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeModeName);
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey) ?? 'system';
  }

  Future<void> saveFontFamily(String fontFamily) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontFamilyKey, fontFamily);
  }

  Future<String> getFontFamily() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fontFamilyKey) ?? 'Noto Sans KR';
  }

  // ★★★ 여기가 추가된 부분입니다 ★★★
  Future<void> resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_wpmKey);
    await prefs.remove(_ratioKey);
    await prefs.remove(_emphasisColorKey);
    await prefs.remove(_themeColorKey);
    await prefs.remove(_themeModeKey);
    await prefs.remove(_fontFamilyKey);
  }
}