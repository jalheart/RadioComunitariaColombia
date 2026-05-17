import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rcc/application/services/audio_player_service.dart';
import 'package:rcc/domain/entities/radio_station.dart';
import 'package:rcc/presentation/widgets/mini_player.dart';
import 'package:rcc/presentation/widgets/station_logo.dart';

class MockAudioPlayerService extends Mock implements AudioPlayerService {}

Widget wrapWithMaterial(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  late MockAudioPlayerService mockAudioService;
  late RadioStation station;

  setUp(() {
    mockAudioService = MockAudioPlayerService();
    station = RadioStation(
      name: 'Radio Colombia',
      url: 'https://radio.com',
      slogan: 'La voz de Colombia',
    );
  });

  group('MiniPlayer', () {
    testWidgets('should render nothing when hasStation is false',
        (tester) async {
      when(() => mockAudioService.hasStation).thenReturn(false);

      await tester.pumpWidget(wrapWithMaterial(
        MiniPlayer(
          audioService: mockAudioService,
          onTap: () {},
        ),
      ));

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Radio Colombia'), findsNothing);
    });

    testWidgets('should render station name when hasStation is true',
        (tester) async {
      when(() => mockAudioService.hasStation).thenReturn(true);
      when(() => mockAudioService.currentStation).thenReturn(station);
      when(() => mockAudioService.isPlaying).thenReturn(true);

      await tester.pumpWidget(wrapWithMaterial(
        MiniPlayer(
          audioService: mockAudioService,
          onTap: () {},
        ),
      ));

      expect(find.text('Radio Colombia'), findsOneWidget);
    });

    testWidgets('should render station slogan when present', (tester) async {
      when(() => mockAudioService.hasStation).thenReturn(true);
      when(() => mockAudioService.currentStation).thenReturn(station);
      when(() => mockAudioService.isPlaying).thenReturn(true);

      await tester.pumpWidget(wrapWithMaterial(
        MiniPlayer(
          audioService: mockAudioService,
          onTap: () {},
        ),
      ));

      expect(find.text('La voz de Colombia'), findsOneWidget);
    });

    testWidgets('should show pause icon when playing', (tester) async {
      when(() => mockAudioService.hasStation).thenReturn(true);
      when(() => mockAudioService.currentStation).thenReturn(station);
      when(() => mockAudioService.isPlaying).thenReturn(true);

      await tester.pumpWidget(wrapWithMaterial(
        MiniPlayer(
          audioService: mockAudioService,
          onTap: () {},
        ),
      ));

      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });

    testWidgets('should show play icon when paused', (tester) async {
      when(() => mockAudioService.hasStation).thenReturn(true);
      when(() => mockAudioService.currentStation).thenReturn(station);
      when(() => mockAudioService.isPlaying).thenReturn(false);

      await tester.pumpWidget(wrapWithMaterial(
        MiniPlayer(
          audioService: mockAudioService,
          onTap: () {},
        ),
      ));

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsNothing);
    });

    testWidgets('should call togglePlayPause when play/pause button pressed',
        (tester) async {
      when(() => mockAudioService.hasStation).thenReturn(true);
      when(() => mockAudioService.currentStation).thenReturn(station);
      when(() => mockAudioService.isPlaying).thenReturn(true);
      when(() => mockAudioService.togglePlayPause()).thenAnswer((_) async {});

      await tester.pumpWidget(wrapWithMaterial(
        MiniPlayer(
          audioService: mockAudioService,
          onTap: () {},
        ),
      ));

      await tester.tap(find.byIcon(Icons.pause));
      verify(() => mockAudioService.togglePlayPause()).called(1);
    });

    testWidgets('should call stop when close button pressed', (tester) async {
      when(() => mockAudioService.hasStation).thenReturn(true);
      when(() => mockAudioService.currentStation).thenReturn(station);
      when(() => mockAudioService.isPlaying).thenReturn(true);
      when(() => mockAudioService.stop()).thenAnswer((_) async {});

      await tester.pumpWidget(wrapWithMaterial(
        MiniPlayer(
          audioService: mockAudioService,
          onTap: () {},
        ),
      ));

      await tester.tap(find.byIcon(Icons.close));
      verify(() => mockAudioService.stop()).called(1);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;
      when(() => mockAudioService.hasStation).thenReturn(true);
      when(() => mockAudioService.currentStation).thenReturn(station);
      when(() => mockAudioService.isPlaying).thenReturn(true);

      await tester.pumpWidget(wrapWithMaterial(
        MiniPlayer(
          audioService: mockAudioService,
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byWidgetPredicate(
        (w) => w is GestureDetector && w.child is Container,
      ));
      expect(tapped, true);
    });

    testWidgets('should use logoUrl when provided', (tester) async {
      when(() => mockAudioService.hasStation).thenReturn(true);
      when(() => mockAudioService.currentStation).thenReturn(station);
      when(() => mockAudioService.isPlaying).thenReturn(true);

      await tester.pumpWidget(wrapWithMaterial(
        MiniPlayer(
          audioService: mockAudioService,
          onTap: () {},
          logoUrl: 'https://example.com/logo.png',
        ),
      ));

      final logo = tester.widget<StationLogo>(find.byType(StationLogo));
      expect(logo.imageUrl, 'https://example.com/logo.png');
    });
  });
}
