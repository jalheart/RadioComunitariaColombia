import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../domain/entities/radio_station.dart';

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  RadioStation? _currentStation;
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _error;
  bool _isMinimized = false;

  RadioStation? get currentStation => _currentStation;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isMinimized => _isMinimized;
  bool get hasStation => _currentStation != null;

  AudioPlayer get audioPlayer => _audioPlayer;

  Future<void> play(RadioStation station) async {
    _currentStation = station;
    _isMinimized = false;
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final streamUrl = station.streamUrl;
      debugPrint('Reproduciendo stream: $streamUrl');
      await _audioPlayer.setUrl(streamUrl);
      await _audioPlayer.play();
      _isPlaying = true;
      _isLoading = false;
      debugPrint('Stream iniciado correctamente');
    } catch (e) {
      _error = 'Error al reproducir: $e';
      _isPlaying = false;
      _isLoading = false;
      debugPrint('Error al reproducir stream: $e');
    }
    notifyListeners();

    _audioPlayer.playerStateStream.listen((state) {
      if (_currentStation != null) {
        _isPlaying = state.playing;
        notifyListeners();
      }
    });
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  void minimize() {
    debugPrint('Minimizing... currentStation: $_currentStation');
    _isMinimized = true;
    notifyListeners();
    debugPrint('Minimized. hasStation: $hasStation');
  }

  void restore() {
    _isMinimized = false;
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentStation = null;
    _isPlaying = false;
    _isMinimized = false;
    _error = null;
    notifyListeners();
  }
}