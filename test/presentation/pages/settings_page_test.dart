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
        ),
      ));

      expect(find.text('Configuración'), findsOneWidget);
    });

    testWidgets('should render theme section title', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        SettingsPage(
          currentColor: 0xFF673AB7,
          onThemeChanged: (_) {},
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
        ),
      ));

      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('should show check icon on selected color', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        SettingsPage(
          currentColor: 0xFF673AB7,
          onThemeChanged: (_) {},
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
        ),
      ));

      final detectors = find.byType(GestureDetector);
      expect(detectors, findsWidgets);

      if (detectors.evaluate().length > 1) {
        await tester.runAsync(() async {
          await tester.tap(detectors.last);
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
        ),
      ));

      expect(find.byIcon(Icons.check), findsNothing);
    });
  });
}
