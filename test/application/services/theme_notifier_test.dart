import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rc/application/ports/settings_port.dart';
import 'package:rc/application/services/theme_notifier.dart';
import 'package:rc/infrastructure/services/settings_service.dart';

class MockSettingsService extends Mock implements SettingsService {}

void main() {
  late ThemeNotifier notifier;
  late MockSettingsService mockService;

  setUp(() {
    mockService = MockSettingsService();
  });

  group('initialization', () {
    test('should load theme color on creation', () async {
      when(() => mockService.getThemeColor())
          .thenAnswer((_) async => 0xFF123456);

      notifier = ThemeNotifier(settingsService: mockService);

      await Future<void>.delayed(Duration.zero);

      expect(notifier.isLoading, false);
      expect(notifier.themeColor, 0xFF123456);
    });

    test('should use default color when service fails', () async {
      when(() => mockService.getThemeColor())
          .thenThrow(Exception('Failed'));

      notifier = ThemeNotifier(settingsService: mockService);

      await Future<void>.delayed(Duration.zero);

      expect(notifier.isLoading, false);
      expect(notifier.themeColor, SettingsPort.getDefaultColor());
    });
  });

  group('setThemeColor', () {
    test('should update color and persist to service', () async {
      when(() => mockService.getThemeColor())
          .thenAnswer((_) async => SettingsPort.getDefaultColor());
      when(() => mockService.setThemeColor(any()))
          .thenAnswer((_) async {});

      notifier = ThemeNotifier(settingsService: mockService);
      await Future<void>.delayed(Duration.zero);

      await notifier.setThemeColor(0xFFABCDEF);

      expect(notifier.themeColor, 0xFFABCDEF);
      verify(() => mockService.setThemeColor(0xFFABCDEF)).called(1);
    });
  });

  group('theme', () {
    test('should return ThemeData with current color', () async {
      when(() => mockService.getThemeColor())
          .thenAnswer((_) async => 0xFF123456);

      notifier = ThemeNotifier(settingsService: mockService);
      await Future<void>.delayed(Duration.zero);

      final theme = notifier.theme;

      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, true);
    });
  });
}
