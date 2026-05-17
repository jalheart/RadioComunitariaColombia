abstract class SettingsPort {
  static final Map<String, int> _themeColors = {
    'deepPurple': 0xFF673AB7,
    'blue': 0xFF2196F3,
    'teal': 0xFF009688,
    'green': 0xFF4CAF50,
    'orange': 0xFFFF9800,
    'red': 0xFFF44336,
    'pink': 0xFFE91E63,
    'purple': 0xFF9C27B0,
    'darkBlue': 0xFF0D47A1,
    'darkGreen': 0xFF1B5E20,
    'darkRed': 0xFFB71C1C,
    'darkPurple': 0xFF4A148C,
    'darkTeal': 0xFF004D40,
    'darkOrange': 0xFFE65100,
    'charcoal': 0xFF37474F,
    'midnight': 0xFF1A237E,
  };

  static List<String> get availableThemes => _themeColors.keys.toList();

  static int getDefaultColor() => _themeColors['deepPurple']!;

  static int getColorByName(String name) => _themeColors[name] ?? getDefaultColor();

  Future<int> getThemeColor();
  Future<void> setThemeColor(int color);
}
