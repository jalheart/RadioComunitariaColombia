import 'package:flutter_test/flutter_test.dart';
import 'package:rcc/application/services/sleep_timer_service.dart';

void main() {
  late SleepTimerService service;

  setUp(() {
    service = SleepTimerService();
  });

  tearDown(() {
    service.dispose();
  });

  group('initial state', () {
    test('should have correct initial values', () {
      expect(service.isActive, false);
      expect(service.remainingSeconds, 0);
      expect(service.durationMinutes, 0);
      expect(service.formattedTime, '00:00');
    });
  });

  group('start', () {
    test('should set active state and correct time values', () {
      service.start(15);

      expect(service.isActive, true);
      expect(service.remainingSeconds, 900);
      expect(service.durationMinutes, 15);
      expect(service.formattedTime, '15:00');
    });

    test('should reset and restart when called while active', () {
      service.start(15);
      service.start(30);

      expect(service.isActive, true);
      expect(service.remainingSeconds, 1800);
      expect(service.durationMinutes, 30);
      expect(service.formattedTime, '30:00');
    });
  });

  group('cancel', () {
    test('should reset state to initial', () {
      service.start(15);
      service.cancel();

      expect(service.isActive, false);
      expect(service.remainingSeconds, 0);
      expect(service.durationMinutes, 0);
      expect(service.formattedTime, '00:00');
    });

    test('should be safe to call when not active', () {
      service.cancel();

      expect(service.isActive, false);
      expect(service.remainingSeconds, 0);
    });

    test('should prevent onExpired from firing', () async {
      var expiredCalled = false;
      service.onExpired = () => expiredCalled = true;

      service.start(0);
      service.cancel();

      await Future.delayed(const Duration(milliseconds: 1100));
      expect(expiredCalled, false);
    });
  });

  group('formattedTime', () {
    test('should format minutes and seconds correctly', () {
      service.start(1);
      expect(service.formattedTime, '01:00');
    });
  });

  group('countdown', () {
    test('should decrement remainingSeconds each second', () async {
      service.start(0);
      expect(service.isActive, true);

      await Future.delayed(const Duration(milliseconds: 1500));
      expect(service.isActive, false);
      expect(service.remainingSeconds, 0);
    });
  });

  group('onExpired callback', () {
    test('should fire when timer reaches zero', () async {
      var expiredCalled = false;
      service.onExpired = () => expiredCalled = true;

      service.start(0);

      await Future.delayed(const Duration(milliseconds: 1500));
      expect(expiredCalled, true);
      expect(service.isActive, false);
    });
  });
}
