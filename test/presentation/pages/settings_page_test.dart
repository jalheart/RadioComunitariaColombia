import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rc/presentation/pages/settings_page.dart';

Widget wrapWithMaterial(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  setUpAll(() {
    final tempDir = Directory.systemTemp.createTempSync('hive_settings_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    final box = await Hive.openBox('settings');
    await box.close();
    Hive.deleteBoxFromDisk('settings');
  });
  group('SettingsPage', () {
    testWidgets('should render app bar with title', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        SettingsPage(
          currentColor: 0xFF673AB7,
          onThemeChanged: (_) {},
          onBrightnessChanged: (_) {},
        ),
      ));

      expect(find.text('Configuración'), findsOneWidget);
    });

    testWidgets('should render theme section title', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        SettingsPage(
          currentColor: 0xFF673AB7,
          onThemeChanged: (_) {},
          onBrightnessChanged: (_) {},
        ),
      ));

      expect(find.text('Tema de la App'), findsOneWidget);
      expect(find.text('Selecciona un color para el tema:'), findsOneWidget);
    });

    testWidgets('should render color circles', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        SettingsPage(
          currentColor: 0xFF673AB7,
          onThemeChanged: (_) {},
          onBrightnessChanged: (_) {},
        ),
      ));

      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('should show check icon on selected color', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        SettingsPage(
          currentColor: 0xFF673AB7,
          onThemeChanged: (_) {},
          onBrightnessChanged: (_) {},
        ),
      ));

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should call onThemeChanged when color is tapped',
        (tester) async {
      int? selectedColor;
      await tester.pumpWidget(wrapWithMaterial(
        SettingsPage(
          currentColor: 0xFF673AB7,
          onThemeChanged: (color) => selectedColor = color,
          onBrightnessChanged: (_) {},
        ),
      ));

      final detectors = find.byType(GestureDetector);
      expect(detectors, findsWidgets);

      if (detectors.evaluate().length > 1) {
        await tester.runAsync(() async {
          await tester.tap(detectors.first);
          await Future.delayed(const Duration(milliseconds: 100));
        });
        await tester.pump();

        expect(selectedColor, isNotNull);
      }
    });

    testWidgets('should not show check when color does not match any theme',
        (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        SettingsPage(
          currentColor: 0xFF000000,
          onThemeChanged: (_) {},
          onBrightnessChanged: (_) {},
        ),
      ));

      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('should render dark mode switch tile', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        SettingsPage(
          currentColor: 0xFF673AB7,
          onThemeChanged: (_) {},
          isDarkMode: false,
          onBrightnessChanged: (_) {},
        ),
      ));

      expect(find.text('Modo oscuro'), findsOneWidget);
      expect(find.text('Desactivado'), findsOneWidget);
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should show dark mode active state', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        SettingsPage(
          currentColor: 0xFF673AB7,
          onThemeChanged: (_) {},
          isDarkMode: true,
          onBrightnessChanged: (_) {},
        ),
      ));

      expect(find.text('Modo oscuro'), findsOneWidget);
      expect(find.text('Activado'), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('should call onBrightnessChanged when switch is toggled',
        (tester) async {
      bool? emitted;
      await tester.pumpWidget(wrapWithMaterial(
        SettingsPage(
          currentColor: 0xFF673AB7,
          onThemeChanged: (_) {},
          isDarkMode: false,
          onBrightnessChanged: (value) => emitted = value,
        ),
      ));

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(emitted, isTrue);
    });
  });
}
