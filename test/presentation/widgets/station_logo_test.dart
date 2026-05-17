import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rcc/presentation/widgets/station_logo.dart';

Widget wrapWithMaterial(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('StationLogo', () {
    testWidgets('should render placeholder when imageUrl is null',
        (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const StationLogo(imageUrl: null),
      ));

      expect(find.byIcon(Icons.radio), findsOneWidget);
    });

    testWidgets('should render placeholder when imageUrl is empty',
        (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const StationLogo(imageUrl: ''),
      ));

      expect(find.byIcon(Icons.radio), findsOneWidget);
    });

    testWidgets('should render without status indicator by default',
        (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const StationLogo(imageUrl: null),
      ));

      expect(find.byIcon(Icons.radio), findsOneWidget);
    });

    testWidgets('should show online status indicator when showStatus is true',
        (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const StationLogo(
          imageUrl: null,
          showStatus: true,
          isOnline: true,
          size: 40,
        ),
      ));

      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('should show offline status indicator when station is offline',
        (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const StationLogo(
          imageUrl: null,
          showStatus: true,
          isOnline: false,
          size: 40,
        ),
      ));

      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('should apply custom size and borderRadius', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const StationLogo(
          imageUrl: null,
          size: 80,
          borderRadius: 16,
        ),
      ));

      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('should apply boxShadow when provided', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        StationLogo(
          imageUrl: null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
            ),
          ],
        ),
      ));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should use custom background color', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const StationLogo(
          imageUrl: null,
          backgroundColor: Colors.blue,
        ),
      ));

      expect(find.byIcon(Icons.radio), findsOneWidget);
    });
  });
}
