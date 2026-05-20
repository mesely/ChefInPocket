import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider extends ChangeNotifier {
  PreferencesProvider() {
    _load();
  }

  static const _themeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  bool _isReady = false;

  ThemeMode get themeMode => _themeMode;
  bool get isReady => _isReady;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_themeModeKey);

    if (value == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    _isReady = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    await preferences.setString(_themeModeKey, enabled ? 'dark' : 'light');
    notifyListeners();
  }
}
