import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rcc/application/ports/settings_port.dart';
import 'package:rcc/application/services/theme_notifier.dart';
import 'package:rcc/infrastructure/services/settings_service.dart';

class MockSettingsService extends Mock implements SettingsService {}

void main() {
  late ThemeNotifier notifier;
  late MockSettingsService mockService;

  setUp(() {
    mockService = MockSettingsService();
  });

  group('initialization', () {
    test('should load theme color and brightness on creation', () async {
      when(() => mockService.getThemeColor())
          .thenAnswer((_) async => 0xFF123456);
      when(() => mockService.getBrightness())
          .thenAnswer((_) async => true);

      notifier = ThemeNotifier(settingsService: mockService);

      await Future<void>.delayed(Duration.zero);

      expect(notifier.isLoading, false);
      expect(notifier.themeColor, 0xFF123456);
      expect(notifier.isDarkMode, true);
    });

    test('should use default color when service fails', () async {
      when(() => mockService.getThemeColor())
          .thenThrow(Exception('Failed'));

      notifier = ThemeNotifier(settingsService: mockService);

      await Future<void>.delayed(Duration.zero);

      expect(notifier.isLoading, false);
      expect(notifier.themeColor, SettingsPort.getDefaultColor());
      expect(notifier.isDarkMode, false);
    });
  });

  group('setThemeColor', () {
    test('should update color and persist to service', () async {
      when(() => mockService.getThemeColor())
          .thenAnswer((_) async => SettingsPort.getDefaultColor());
      when(() => mockService.getBrightness())
          .thenAnswer((_) async => false);
      when(() => mockService.setThemeColor(any()))
          .thenAnswer((_) async {});

      notifier = ThemeNotifier(settingsService: mockService);
      await Future<void>.delayed(Duration.zero);

      await notifier.setThemeColor(0xFFABCDEF);

      expect(notifier.themeColor, 0xFFABCDEF);
      verify(() => mockService.setThemeColor(0xFFABCDEF)).called(1);
    });
  });

  group('setBrightness', () {
    test('should update brightness and persist to service', () async {
      when(() => mockService.getThemeColor())
          .thenAnswer((_) async => SettingsPort.getDefaultColor());
      when(() => mockService.getBrightness())
          .thenAnswer((_) async => false);
      when(() => mockService.setBrightness(any()))
          .thenAnswer((_) async {});

      notifier = ThemeNotifier(settingsService: mockService);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.isDarkMode, false);

      await notifier.setBrightness(true);

      expect(notifier.isDarkMode, true);
      verify(() => mockService.setBrightness(true)).called(1);
    });

    test('should toggle brightness back to light', () async {
      when(() => mockService.getThemeColor())
          .thenAnswer((_) async => SettingsPort.getDefaultColor());
      when(() => mockService.getBrightness())
          .thenAnswer((_) async => true);
      when(() => mockService.setBrightness(any()))
          .thenAnswer((_) async {});

      notifier = ThemeNotifier(settingsService: mockService);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.isDarkMode, true);

      await notifier.setBrightness(false);

      expect(notifier.isDarkMode, false);
      verify(() => mockService.setBrightness(false)).called(1);
    });
  });

  group('theme', () {
    test('should return ThemeData with current color and light brightness',
        () async {
      when(() => mockService.getThemeColor())
          .thenAnswer((_) async => 0xFF123456);
      when(() => mockService.getBrightness())
          .thenAnswer((_) async => false);

      notifier = ThemeNotifier(settingsService: mockService);
      await Future<void>.delayed(Duration.zero);

      final theme = notifier.theme;

      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, true);
      expect(theme.brightness, Brightness.light);
    });

    test('should return ThemeData with dark brightness', () async {
      when(() => mockService.getThemeColor())
          .thenAnswer((_) async => 0xFF123456);
      when(() => mockService.getBrightness())
          .thenAnswer((_) async => true);

      notifier = ThemeNotifier(settingsService: mockService);
      await Future<void>.delayed(Duration.zero);

      final theme = notifier.theme;

      expect(theme, isA<ThemeData>());
      expect(theme.brightness, Brightness.dark);
    });
  });
}
