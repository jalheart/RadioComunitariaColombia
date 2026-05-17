import 'package:hive_flutter/hive_flutter.dart';
import '../../application/ports/settings_port.dart';

class SettingsService implements SettingsPort {
  static const String _boxName = 'settings';
  static const String _themeKey = 'theme_color';

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
}
