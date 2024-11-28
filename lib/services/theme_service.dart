import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeModeKey = 'theme_mode';

  static final ThemeService instance = ThemeService._();
  ThemeService._();

  final _themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
  ValueNotifier<ThemeMode> get themeMode => _themeMode;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getInt(_themeModeKey);
    if (savedThemeMode != null) {
      _themeMode.value = ThemeMode.values[savedThemeMode];
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    _themeMode.value = mode;
  }
}
