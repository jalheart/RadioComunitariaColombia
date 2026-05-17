import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rc/application/services/audio_player_service.dart';
import 'package:rc/domain/entities/radio_station.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class FakeDuration extends Fake implements Duration {}

class FakePlayerState extends Fake implements PlayerState {}

void main() {
  late AudioPlayerService service;
  late MockAudioPlayer mockPlayer;
  late RadioStation station;
  late RadioStation otherStation;

  setUpAll(() {
    registerFallbackValue(FakeDuration());
    registerFallbackValue(FakePlayerState());
  });

  setUp(() {
    mockPlayer = MockAudioPlayer();
    service = AudioPlayerService(audioPlayer: mockPlayer);
    station = RadioStation(
      name: 'Radio Colombia',
      url: 'https://radios.miservidor.cloud/cp/widgets/player/single/?p=8287',
      port: '8287',
    );
    otherStation = RadioStation(
      name: 'Radio Bogotá',
      url: 'https://bogota.com/podcast?p=8080',
      port: '8080',
    );
  });

  group('initial state', () {
    test('should have correct initial values', () {
      expect(service.isPlaying, false);
      expect(service.isLoading, false);
      expect(service.isBuffering, false);
      expect(service.currentStation, isNull);
      expect(service.error, isNull);
      expect(service.isMinimized, false);
      expect(service.hasStation, false);
    });
  });

  group('play()', () {
    setUp(() {
      when(() => mockPlayer.setUrl(any())).thenAnswer((_) async => null);
      when(() => mockPlayer.play()).thenAnswer((_) async {});
      when(() => mockPlayer.pause()).thenAnswer((_) async {});
      when(() => mockPlayer.stop()).thenAnswer((_) async {});
      when(() => mockPlayer.playerStateStream)
          .thenAnswer((_) => const Stream.empty());
    });

    test('should set current station and start playing', () async {
      await service.play(station);

      expect(service.currentStation, station);
      expect(service.isPlaying, true);
      expect(service.isLoading, false);
      expect(service.error, isNull);
      expect(service.hasStation, true);
      expect(service.isMinimized, false);
    });

    test('should call setUrl with station streamUrl', () async {
      await service.play(station);

      verify(() => mockPlayer.setUrl(station.streamUrl)).called(1);
    });

    test('should call play on audio player', () async {
      await service.play(station);

      verify(() => mockPlayer.play()).called(1);
    });

    test('should not re-setUrl when playing same station', () async {
      await service.play(station);
      await service.play(station);

      verify(() => mockPlayer.setUrl(any())).called(1);
    });

    test('should un-minimize when playing same station while minimized',
        () async {
      service.minimize();
      expect(service.isMinimized, true);

      await service.play(station);

      expect(service.isMinimized, false);
      expect(service.isPlaying, true);
    });

    test('should resume playback when playing same paused station',
        () async {
      await service.play(station);
      expect(service.isPlaying, true);

      await service.pause();
      expect(service.isPlaying, false);

      await service.play(station);
      expect(service.isPlaying, true);
    });

    test('should stop previous and play new when changing station',
        () async {
      await service.play(station);
      await service.play(otherStation);

      verify(() => mockPlayer.stop()).called(1);
      verify(() => mockPlayer.setUrl(otherStation.streamUrl)).called(1);
      expect(service.currentStation, otherStation);
      expect(service.isPlaying, true);
    });

    test('should set error when setUrl fails', () async {
      when(() => mockPlayer.setUrl(any()))
          .thenThrow(Exception('network error'));

      await service.play(station);

      expect(service.error, 'Parece que estás offline');
      expect(service.isPlaying, false);
      expect(service.isLoading, false);
    });

    test('should subscribe to playerStateStream', () async {
      await service.play(station);

      verify(() => mockPlayer.playerStateStream).called(1);
    });

    test('should update isPlaying from playerStateStream', () async {
      final controller = StreamController<PlayerState>();
      when(() => mockPlayer.playerStateStream)
          .thenAnswer((_) => controller.stream);

      await service.play(station);

        controller.add(PlayerState(false, ProcessingState.idle));
      await Future<void>.delayed(Duration.zero);

      expect(service.isPlaying, false);
      expect(service.isBuffering, false);

      await controller.close();
    });

    test('should update isBuffering from playerStateStream', () async {
      final controller = StreamController<PlayerState>();
      when(() => mockPlayer.playerStateStream)
          .thenAnswer((_) => controller.stream);

      await service.play(station);

        controller.add(PlayerState(true, ProcessingState.buffering));
      await Future<void>.delayed(Duration.zero);

      expect(service.isPlaying, true);
      expect(service.isBuffering, true);

      await controller.close();
    });
  });

  group('pause()', () {
    test('should pause audio and update state', () async {
      when(() => mockPlayer.pause()).thenAnswer((_) async {});

      await service.pause();

      verify(() => mockPlayer.pause()).called(1);
      expect(service.isPlaying, false);
      expect(service.isBuffering, false);
    });
  });

  group('resume()', () {
    test('should resume audio and update state', () async {
      when(() => mockPlayer.play()).thenAnswer((_) async {});

      await service.resume();

      verify(() => mockPlayer.play()).called(1);
      expect(service.isPlaying, true);
    });
  });

  group('togglePlayPause()', () {
    test('should pause when currently playing', () async {
      when(() => mockPlayer.setUrl(any())).thenAnswer((_) async => null);
      when(() => mockPlayer.play()).thenAnswer((_) async {});
      when(() => mockPlayer.playerStateStream)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockPlayer.pause()).thenAnswer((_) async {});

      await service.play(station);
      await service.togglePlayPause();

      verify(() => mockPlayer.pause()).called(1);
      expect(service.isPlaying, false);
    });

    test('should resume when currently paused', () async {
      when(() => mockPlayer.play()).thenAnswer((_) async {});

      await service.togglePlayPause();

      verify(() => mockPlayer.play()).called(1);
      expect(service.isPlaying, true);
    });
  });

  group('stop()', () {
    setUp(() {
      when(() => mockPlayer.setUrl(any())).thenAnswer((_) async => null);
      when(() => mockPlayer.play()).thenAnswer((_) async {});
      when(() => mockPlayer.playerStateStream)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockPlayer.stop()).thenAnswer((_) async {});
    });

    test('should reset station and state', () async {
      await service.play(station);
      await service.stop();

      expect(service.currentStation, isNull);
      expect(service.isPlaying, false);
      expect(service.isBuffering, false);
      expect(service.isMinimized, false);
      expect(service.error, isNull);
      expect(service.hasStation, false);
    });

    test('should call stop on audio player', () async {
      await service.play(station);
      await service.stop();

      verify(() => mockPlayer.stop()).called(1);
    });

    test('should work when no station is playing', () async {
      await service.stop();

      expect(service.currentStation, isNull);
      expect(service.isPlaying, false);
    });
  });

  group('minimize()', () {
    test('should set isMinimized to true', () {
      service.minimize();

      expect(service.isMinimized, true);
    });

    test('hasStation should still be true after minimize when station loaded',
        () async {
      when(() => mockPlayer.setUrl(any())).thenAnswer((_) async => null);
      when(() => mockPlayer.play()).thenAnswer((_) async {});
      when(() => mockPlayer.playerStateStream)
          .thenAnswer((_) => const Stream.empty());

      await service.play(station);
      service.minimize();

      expect(service.hasStation, true);
      expect(service.isMinimized, true);
    });
  });

  group('restore()', () {
    test('should set isMinimized to false', () {
      service.minimize();
      service.restore();

      expect(service.isMinimized, false);
    });
  });

  group('dispose()', () {
    test('should dispose audio player', () async {
      when(() => mockPlayer.dispose()).thenAnswer((_) async {});

      service.dispose();

      verify(() => mockPlayer.dispose()).called(1);
    });

    test('should cancel subscription when disposed after play', () async {
      when(() => mockPlayer.setUrl(any())).thenAnswer((_) async => null);
      when(() => mockPlayer.play()).thenAnswer((_) async {});
      when(() => mockPlayer.playerStateStream)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockPlayer.dispose()).thenAnswer((_) async {});

      await service.play(station);
      service.dispose();

      verify(() => mockPlayer.dispose()).called(1);
    });
  });
}
