import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rc/application/services/rcc_audio_handler.dart';
import 'package:rc/domain/entities/radio_station.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class FakeDuration extends Fake implements Duration {}

void main() {
  late MockAudioPlayer mockPlayer;
  late RCCAudioHandler handler;
  late RadioStation station;

  setUpAll(() {
    registerFallbackValue(FakeDuration());
  });

  setUp(() {
    mockPlayer = MockAudioPlayer();
    when(() => mockPlayer.playerStateStream)
        .thenAnswer((_) => const Stream.empty());

    handler = RCCAudioHandler(audioPlayer: mockPlayer);

    station = RadioStation(
      name: 'Radio Colombia',
      url: 'https://radios.miservidor.cloud/cp/widgets/player/single/?p=8287',
      port: '8287',
      slogan: 'La voz de la comunidad',
      logo: 'https://logo.com/logo.png',
    );
  });

  group('play()', () {
    test('should delegate to player play', () async {
      when(() => mockPlayer.play()).thenAnswer((_) async {});

      await handler.play();

      verify(() => mockPlayer.play()).called(1);
    });
  });

  group('pause()', () {
    test('should delegate to player pause', () async {
      when(() => mockPlayer.pause()).thenAnswer((_) async {});

      await handler.pause();

      verify(() => mockPlayer.pause()).called(1);
    });
  });

  group('stop()', () {
    test('should delegate to player stop', () async {
      when(() => mockPlayer.stop()).thenAnswer((_) async {});

      await handler.stop();

      verify(() => mockPlayer.stop()).called(1);
    });
  });

  group('setStation()', () {
    test('should set URL without playing', () async {
      when(() => mockPlayer.setUrl(any())).thenAnswer((_) async => null);

      await handler.setStation(station);

      verify(() => mockPlayer.setUrl(station.streamUrl)).called(1);
      verifyNever(() => mockPlayer.play());
    });

    test('should update mediaItem with station metadata', () async {
      when(() => mockPlayer.setUrl(any())).thenAnswer((_) async => null);

      MediaItem? emitted;
      handler.mediaItem.listen((item) => emitted = item);

      await handler.setStation(station);

      expect(emitted, isNotNull);
      expect(emitted!.id, station.url);
      expect(emitted!.title, station.name);
      expect(emitted!.artist, station.slogan);
      expect(emitted!.artUri, Uri.parse(station.logo!));
    });

    test('should use default artist when slogan is null', () async {
      when(() => mockPlayer.setUrl(any())).thenAnswer((_) async => null);

      final stationNoSlogan = RadioStation(
        name: 'Test Radio',
        url: 'https://test.com',
      );

      MediaItem? emitted;
      handler.mediaItem.listen((item) => emitted = item);

      await handler.setStation(stationNoSlogan);

      expect(emitted!.artist, 'Radio Comunitaria Colombia');
    });

    test('should handle null logo gracefully', () async {
      when(() => mockPlayer.setUrl(any())).thenAnswer((_) async => null);

      final stationNoLogo = RadioStation(
        name: 'Test Radio',
        url: 'https://test.com',
      );

      MediaItem? emitted;
      handler.mediaItem.listen((item) => emitted = item);

      await handler.setStation(stationNoLogo);

      expect(emitted!.artUri, isNull);
    });
  });

  group('onTaskRemoved()', () {
    test('should call stop', () async {
      when(() => mockPlayer.stop()).thenAnswer((_) async {});

      await handler.onTaskRemoved();

      verify(() => mockPlayer.stop()).called(1);
    });
  });

  group('playerStateStream', () {
    test('should forward playing state to playbackState', () async {
      final controller = StreamController<PlayerState>();
      when(() => mockPlayer.playerStateStream)
          .thenAnswer((_) => controller.stream);

      // Recreate handler with controlled stream
      handler = RCCAudioHandler(audioPlayer: mockPlayer);

      PlaybackState? emitted;
      handler.playbackState.listen((state) => emitted = state);

      controller.add(PlayerState(true, ProcessingState.ready));
      await Future<void>.delayed(Duration.zero);

      expect(emitted, isNotNull);
      expect(emitted!.playing, true);

      await controller.close();
    });

    test('should forward buffering state to playbackState', () async {
      final controller = StreamController<PlayerState>();
      when(() => mockPlayer.playerStateStream)
          .thenAnswer((_) => controller.stream);

      handler = RCCAudioHandler(audioPlayer: mockPlayer);

      PlaybackState? emitted;
      handler.playbackState.listen((state) => emitted = state);

      controller.add(PlayerState(false, ProcessingState.buffering));
      await Future<void>.delayed(Duration.zero);

      expect(emitted, isNotNull);
      expect(emitted!.playing, false);
      expect(emitted!.processingState, AudioProcessingState.buffering);

      await controller.close();
    });
  });

  group('shutdown()', () {
    test('should dispose the player', () async {
      when(() => mockPlayer.dispose()).thenAnswer((_) async {});

      handler.shutdown();

      verify(() => mockPlayer.dispose()).called(1);
    });
  });

  group('seek()', () {
    test('should delegate to player seek', () async {
      when(() => mockPlayer.seek(any())).thenAnswer((_) async {});

      await handler.seek(const Duration(seconds: 30));

      verify(() => mockPlayer.seek(const Duration(seconds: 30))).called(1);
    });
  });

  group('stop()', () {
    test('should clear mediaItem', () async {
      when(() => mockPlayer.stop()).thenAnswer((_) async {});

      MediaItem? emitted;
      handler.mediaItem.listen((item) => emitted = item);

      await handler.stop();

      expect(emitted, isNull);
    });
  });

  group('lock screen controls', () {
    test('should show play and stop controls when loading station', () async {
      when(() => mockPlayer.setUrl(any())).thenAnswer((_) async => null);

      PlaybackState? emitted;
      handler.playbackState.listen((state) => emitted = state);

      await handler.setStation(station);

      expect(emitted, isNotNull);
      expect(emitted!.controls.length, 2);
      expect(emitted!.controls[0], MediaControl.play);
      expect(emitted!.controls[1], MediaControl.stop);
    });

    test('should update to pause control when playing', () async {
      final controller = StreamController<PlayerState>();
      when(() => mockPlayer.playerStateStream)
          .thenAnswer((_) => controller.stream);

      handler = RCCAudioHandler(audioPlayer: mockPlayer);

      PlaybackState? emitted;
      handler.playbackState.listen((state) => emitted = state);

      controller.add(PlayerState(true, ProcessingState.ready));
      await Future<void>.delayed(Duration.zero);

      expect(emitted, isNotNull);
      expect(emitted!.controls.length, 2);
      expect(emitted!.controls[0], MediaControl.pause);
      expect(emitted!.controls[1], MediaControl.stop);

      await controller.close();
    });

    test('should update to play control when paused', () async {
      final controller = StreamController<PlayerState>();
      when(() => mockPlayer.playerStateStream)
          .thenAnswer((_) => controller.stream);

      handler = RCCAudioHandler(audioPlayer: mockPlayer);

      PlaybackState? emitted;
      handler.playbackState.listen((state) => emitted = state);

      controller.add(PlayerState(false, ProcessingState.ready));
      await Future<void>.delayed(Duration.zero);

      expect(emitted, isNotNull);
      expect(emitted!.controls.length, 2);
      expect(emitted!.controls[0], MediaControl.play);
      expect(emitted!.controls[1], MediaControl.stop);

      await controller.close();
    });

    test('should clear controls when stopped', () async {
      when(() => mockPlayer.stop()).thenAnswer((_) async {});

      PlaybackState? emitted;
      handler.playbackState.listen((state) => emitted = state);

      await handler.stop();

      expect(emitted, isNotNull);
      expect(emitted!.controls, isEmpty);
    });
  });
}
