import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:rc/main.dart';

void main() {
  setUpAll(() {
    final tempDir = Directory.systemTemp.createTempSync('hive_smoke_test_');
    Hive.init(tempDir.path);
  });

  testWidgets('App renders loading state', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(MyApp), findsOneWidget);
  });
}
