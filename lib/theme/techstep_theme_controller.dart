import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TechStepThemeController extends ChangeNotifier {
  TechStepThemeController._();

  static final TechStepThemeController instance =
      TechStepThemeController._();

  static const String _themeKey = 'techstep_theme_mode';

  final SharedPreferencesAsync _preferences =
      SharedPreferencesAsync();

  ThemeMode _mode = ThemeMode.light;
  bool _loaded = false;

  ThemeMode get mode => _mode;

  bool get isDarkMode => _mode == ThemeMode.dark;

  Future<void> load() async {
    if (_loaded) return;

    _loaded = true;

    try {
      final savedMode =
          await _preferences.getString(_themeKey);

      _mode = savedMode == 'dark'
          ? ThemeMode.dark
          : ThemeMode.light;
    } catch (_) {
      _mode = ThemeMode.light;
    }

    notifyListeners();
  }

  Future<void> setMode(ThemeMode newMode) async {
    if (newMode == ThemeMode.system) return;
    if (_mode == newMode) return;

    _mode = newMode;
    notifyListeners();

    await _preferences.setString(
      _themeKey,
      newMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}