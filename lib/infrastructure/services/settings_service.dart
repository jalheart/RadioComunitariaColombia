import 'package:hive_flutter/hive_flutter.dart';
import '../../application/ports/settings_port.dart';

class SettingsService implements SettingsPort {
  static const String _boxName = 'settings';
  static const String _themeKey = 'theme_color';
  static const String _brightnessKey = 'brightness';

  @override
  Future<int> getThemeColor() async {
    try {
      final box = await Hive.openBox(_boxName);
      return box.get(_themeKey, defaultValue: SettingsPort.getDefaultColor()) as int;
    } catch (_) {
      return SettingsPort.getDefaultColor();
    }
  }

  @override
  Future<void> setThemeColor(int color) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_themeKey, color);
    } catch (_) {}
  }

  @override
  Future<bool> getBrightness() async {
    try {
      final box = await Hive.openBox(_boxName);
      return box.get(_brightnessKey, defaultValue: false) as bool;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setBrightness(bool isDark) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_brightnessKey, isDark);
    } catch (_) {}
  }
}
