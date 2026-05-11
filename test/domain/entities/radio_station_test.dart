import 'package:flutter_test/flutter_test.dart';
import 'package:rc/domain/entities/radio_station.dart';

void main() {
  group('RadioStation', () {
    test('should create RadioStation with required fields', () {
      final station = RadioStation(
        name: 'Radio Colombia',
        url: 'https://radio.com',
      );

      expect(station.name, 'Radio Colombia');
      expect(station.url, 'https://radio.com');
      expect(station.port, isNull);
      expect(station.logo, isNull);
      expect(station.slogan, isNull);
    });

    test('should support optional fields', () {
      final station = RadioStation(
        name: 'Radio Colombia',
        url: 'https://radio.com',
        port: '8080',
        logo: 'https://logo.com/logo.png',
        slogan: 'La voz de la comunidad',
      );

      expect(station.port, '8080');
      expect(station.logo, 'https://logo.com/logo.png');
      expect(station.slogan, 'La voz de la comunidad');
    });

    test('copyWith should create new instance with updated values', () {
      final original = RadioStation(
        name: 'Original',
        url: 'https://original.com',
      );

      final copy = original.copyWith(name: 'Updated');

      expect(copy.name, 'Updated');
      expect(copy.url, 'https://original.com');
      expect(copy.port, isNull);
    });

    test('copyWith should preserve original values when not updated', () {
      final original = RadioStation(
        name: 'Radio',
        url: 'https://radio.com',
        port: '8080',
        logo: 'https://logo.com',
        slogan: 'Slogan',
      );

      final copy = original.copyWith();

      expect(copy.name, original.name);
      expect(copy.url, original.url);
      expect(copy.port, original.port);
      expect(copy.logo, original.logo);
      expect(copy.slogan, original.slogan);
    });

    test('should have correct equality', () {
      final station1 = RadioStation(
        name: 'Radio Colombia',
        url: 'https://radio.com',
      );

      final station2 = RadioStation(
        name: 'Radio Colombia',
        url: 'https://radio.com',
      );

      final station3 = RadioStation(
        name: 'Different',
        url: 'https://radio.com',
      );

      expect(station1 == station2, isTrue);
      expect(station1 == station3, isFalse);
    });

    test('should have consistent hashCode for equal objects', () {
      final station1 = RadioStation(
        name: 'Radio Colombia',
        url: 'https://radio.com',
      );

      final station2 = RadioStation(
        name: 'Radio Colombia',
        url: 'https://radio.com',
      );

      expect(station1.hashCode, equals(station2.hashCode));
    });

    test('toString should return correct representation', () {
      final station = RadioStation(
        name: 'Radio Colombia',
        url: 'https://radio.com',
      );

      expect(
        station.toString(),
        'RadioStation(name: Radio Colombia, url: https://radio.com, port: null, logo: null, slogan: null)',
      );
    });
  });
}