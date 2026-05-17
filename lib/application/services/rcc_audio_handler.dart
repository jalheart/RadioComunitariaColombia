import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../../domain/entities/radio_station.dart';

class RCCAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _interruptionSubscription;
  StreamSubscription? _noisySubscription;

  RCCAudioHandler({AudioPlayer? audioPlayer})
      : _player = audioPlayer ?? AudioPlayer() {
    _playerStateSubscription = _player.playerStateStream.listen(_onPlayerStateChanged);
  }

  Future<void> initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _interruptionSubscription = session.interruptionEventStream.listen((event) {
      if (event.begin) {
        if (event.type == AudioInterruptionType.pause ||
            event.type == AudioInterruptionType.unknown) {
          _player.pause();
          playbackState.add(playbackState.value.copyWith(
            playing: false,
            processingState: AudioProcessingState.ready,
          ));
        }
      } else {
        if (event.type == AudioInterruptionType.pause) {
          unawaited(_player.play());
          playbackState.add(playbackState.value.copyWith(
            playing: true,
          ));
        }
      }
    });

    _noisySubscription = session.becomingNoisyEventStream.listen((_) {
      _player.pause();
      playbackState.add(playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.ready,
      ));
    });
  }

  void _onPlayerStateChanged(PlayerState state) {
    playbackState.add(playbackState.value.copyWith(
      playing: state.playing,
      processingState: _mapProcessingState(state.processingState),
    ));
  }

  static AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  Future<void> setStation(RadioStation station) async {
    final streamUrl = station.streamUrl;

    mediaItem.add(MediaItem(
      id: station.url,
      title: station.name,
      artist: station.slogan ?? 'Radio Comunitaria Colombia',
      artUri: station.logo != null ? Uri.tryParse(station.logo!) : null,
    ));

    playbackState.add(playbackState.value.copyWith(
      playing: true,
      processingState: AudioProcessingState.ready,
      controls: [
        MediaControl.pause,
        MediaControl.stop,
      ],
      androidCompactActionIndices: const [0, 1],
    ));

    await _player.setUrl(streamUrl);
    _player.play();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    mediaItem.add(null);
    playbackState.add(PlaybackState(
      playing: false,
      processingState: AudioProcessingState.idle,
      controls: [],
      androidCompactActionIndices: const [],
    ));
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  AudioPlayer get player => _player;

  Future<void> reloadUrl(String url) async {
    await _player.setUrl(url);
  }

  void shutdown() {
    _playerStateSubscription?.cancel();
    _interruptionSubscription?.cancel();
    _noisySubscription?.cancel();
    _player.dispose();
  }
}
