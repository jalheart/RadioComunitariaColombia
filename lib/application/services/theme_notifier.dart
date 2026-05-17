import 'package:flutter/material.dart';
import '../../infrastructure/services/settings_service.dart';
import '../ports/settings_port.dart';

class ThemeNotifier extends ChangeNotifier {
  final SettingsService _settingsService;

  ThemeNotifier({SettingsService? settingsService})
      : _settingsService = settingsService ?? SettingsService() {
    _loadTheme();
  }

  int _themeColor = SettingsPort.getDefaultColor();
  bool _isLoading = true;
  bool _isDarkMode = false;

  int get themeColor => _themeColor;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;

  Future<void> _loadTheme() async {
    try {
      _themeColor = await _settingsService.getThemeColor();
      _isDarkMode = await _settingsService.getBrightness();
    } catch (_) {
      _themeColor = SettingsPort.getDefaultColor();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setThemeColor(int color) async {
    _themeColor = color;
    await _settingsService.setThemeColor(color);
    notifyListeners();
  }

  Future<void> setBrightness(bool isDark) async {
    _isDarkMode = isDark;
    await _settingsService.setBrightness(isDark);
    notifyListeners();
  }

  ThemeData get theme => ThemeData(
    brightness: _isDarkMode ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(_themeColor),
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
    ),
    useMaterial3: true,
  );
}