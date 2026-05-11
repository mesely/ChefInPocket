import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider extends ChangeNotifier {
  PreferencesProvider() {
    _load();
  }

  static const _keyTheme = 'theme_mode';
  static const _keyLastTab = 'last_tab';

  ThemeMode _themeMode = ThemeMode.light;
  int _lastTab = 0;

  ThemeMode get themeMode => _themeMode;
  int get lastTab => _lastTab;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyTheme);
    if (saved == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    _lastTab = prefs.getInt(_keyLastTab) ?? 0;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> toggleTheme() async {
    await setThemeMode(_themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setLastTab(int index) async {
    _lastTab = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastTab, index);
  }
}
