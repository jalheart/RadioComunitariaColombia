import '../../domain/entities/radio_station.dart';

abstract class AudioPort {
  RadioStation? get currentStation;
  bool get isPlaying;
  bool get isLoading;
  bool get isBuffering;
  bool get isMinimized;
  bool get hasStation;
  String? get error;

  Future<void> play(RadioStation station);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> togglePlayPause();
  void minimize();
  void restore();
}
