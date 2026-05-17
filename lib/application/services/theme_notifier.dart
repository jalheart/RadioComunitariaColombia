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

  int get themeColor => _themeColor;
  bool get isLoading => _isLoading;

  Future<void> _loadTheme() async {
    try {
      _themeColor = await _settingsService.getThemeColor();
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

  ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(_themeColor),
    ),
    useMaterial3: true,
  );
}