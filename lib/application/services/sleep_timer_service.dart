import 'dart:async';

import 'package:flutter/material.dart';

class SleepTimerService extends ChangeNotifier {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _durationMinutes = 0;
  bool _isActive = false;
  VoidCallback? onExpired;

  bool get isActive => _isActive;
  int get remainingSeconds => _remainingSeconds;
  int get durationMinutes => _durationMinutes;

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final m = minutes.toString().padLeft(2, '0');
    final s = seconds.toString().padLeft(2, '0');
    return '$m:$s';
  }

  void start(int minutes) {
    cancel();
    _durationMinutes = minutes;
    _remainingSeconds = minutes * 60;
    _isActive = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _expire();
      }
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _isActive = false;
    _remainingSeconds = 0;
    _durationMinutes = 0;
    notifyListeners();
  }

  void _expire() {
    _timer?.cancel();
    _timer = null;
    _isActive = false;
    _remainingSeconds = 0;
    _durationMinutes = 0;
    notifyListeners();
    onExpired?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
