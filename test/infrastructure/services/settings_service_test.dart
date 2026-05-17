import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rcc/application/ports/settings_port.dart';
import 'package:rcc/infrastructure/services/settings_service.dart';

void main() {
  late SettingsService service;

  setUpAll(() {
    final tempDir = Directory.systemTemp.createTempSync('hive_settings_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    service = SettingsService();
    final box = await Hive.openBox('settings');
    await box.clear();
  });

  tearDownAll(() async {
    final box = await Hive.openBox('settings');
    await box.close();
    Hive.deleteBoxFromDisk('settings');
  });

  group('getThemeColor', () {
    test('should return default color when no value is saved', () async {
      final result = await service.getThemeColor();

      expect(result, SettingsPort.getDefaultColor());
    });

    test('should return saved value after setThemeColor', () async {
      await service.setThemeColor(0xFF123456);

      final result = await service.getThemeColor();

      expect(result, 0xFF123456);
    });
  });

  group('setThemeColor', () {
    test('should persist theme color to Hive box', () async {
      await service.setThemeColor(0xFFABCDEF);

      final box = await Hive.openBox('settings');
      final saved = box.get('theme_color');

      expect(saved, 0xFFABCDEF);
    });

    test('should overwrite previous theme color', () async {
      await service.setThemeColor(0xFF111111);
      await service.setThemeColor(0xFF222222);

      final result = await service.getThemeColor();

      expect(result, 0xFF222222);
    });
  });

  group('getBrightness', () {
    test('should return false (light) when no value is saved', () async {
      final result = await service.getBrightness();

      expect(result, false);
    });

    test('should return saved value after setBrightness', () async {
      await service.setBrightness(true);

      final result = await service.getBrightness();

      expect(result, true);
    });
  });

  group('setBrightness', () {
    test('should persist brightness to Hive box', () async {
      await service.setBrightness(true);

      final box = await Hive.openBox('settings');
      final saved = box.get('brightness');

      expect(saved, true);
    });

    test('should overwrite previous brightness', () async {
      await service.setBrightness(true);
      await service.setBrightness(false);

      final result = await service.getBrightness();

      expect(result, false);
    });
  });
}
