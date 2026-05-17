import 'package:flutter_test/flutter_test.dart';
import 'package:rc/domain/entities/station_metadata.dart';

void main() {
  group('StationMetadata', () {
    group('fromJson', () {
      test('should parse complete JSON correctly', () {
        final json = {
          'history': ['Song 1', 'Song 2'],
          'title': 'Current Song',
          'art': 'https://example.com/art.jpg',
          'ulisteners': 100,
          'listeners': 50,
          'bitrate': 128000,
        };

        final metadata = StationMetadata.fromJson(json);

        expect(metadata.history, ['Song 1', 'Song 2']);
        expect(metadata.title, 'Current Song');
        expect(metadata.art, 'https://example.com/art.jpg');
        expect(metadata.ulisteners, 100);
        expect(metadata.listeners, 50);
        expect(metadata.bitrate, 128000);
      });

      test('should handle missing optional fields', () {
        final json = {
          'history': ['Song'],
          'listeners': 10,
          'bitrate': 64000,
        };

        final metadata = StationMetadata.fromJson(json);

        expect(metadata.title, isNull);
        expect(metadata.art, isNull);
        expect(metadata.ulisteners, 0);
      });

      test('should handle null fields gracefully', () {
        final json = {
          'history': null,
          'title': null,
          'art': null,
          'ulisteners': null,
          'listeners': null,
          'bitrate': null,
        };

        final metadata = StationMetadata.fromJson(json);

        expect(metadata.history, isEmpty);
        expect(metadata.title, isNull);
        expect(metadata.art, isNull);
        expect(metadata.ulisteners, 0);
        expect(metadata.listeners, 0);
        expect(metadata.bitrate, 0);
      });

      test('should parse string numbers for int fields', () {
        final json = {
          'history': ['Song'],
          'title': 'Current',
          'listeners': '25',
          'bitrate': '128000',
          'ulisteners': '50',
        };

        final metadata = StationMetadata.fromJson(json);

        expect(metadata.listeners, 25);
        expect(metadata.bitrate, 128000);
        expect(metadata.ulisteners, 50);
      });

      test('should fallback to ulisteners from ulistener key', () {
        final json = {
          'history': ['Song'],
          'title': 'Current',
          'ulistener': 75,
          'listeners': 50,
          'bitrate': 128000,
        };

        final metadata = StationMetadata.fromJson(json);

        expect(metadata.ulisteners, 75);
      });
    });

    group('isOnline', () {
      test('should return true with valid data', () {
        final metadata = StationMetadata(
          history: ['Song 1'],
          title: 'Current Song',
          ulisteners: 100,
          listeners: 50,
          bitrate: 128000,
        );

        expect(metadata.isOnline, isTrue);
      });

      test('should return false when history is empty', () {
        final metadata = StationMetadata(
          history: [],
          title: 'Current Song',
          ulisteners: 100,
          listeners: 50,
          bitrate: 128000,
        );

        expect(metadata.isOnline, isFalse);
      });

      test('should return false when title is null', () {
        final metadata = StationMetadata(
          history: ['Song 1'],
          title: null,
          ulisteners: 100,
          listeners: 50,
          bitrate: 128000,
        );

        expect(metadata.isOnline, isFalse);
      });

      test('should return false when title is empty', () {
        final metadata = StationMetadata(
          history: ['Song 1'],
          title: '',
          ulisteners: 100,
          listeners: 50,
          bitrate: 128000,
        );

        expect(metadata.isOnline, isFalse);
      });

      test('should return false from JSON when history is empty', () {
        final json = {
          'history': [],
          'title': 'Current Song',
          'listeners': 50,
          'bitrate': 128000,
        };

        final metadata = StationMetadata.fromJson(json);

        expect(metadata.isOnline, isFalse);
      });

      test('should return false from JSON when history is missing', () {
        final json = {
          'title': 'Current Song',
          'listeners': 50,
          'bitrate': 128000,
        };

        final metadata = StationMetadata.fromJson(json);

        expect(metadata.isOnline, isFalse);
      });

      test('should return false from JSON when title is empty', () {
        final json = {
          'history': ['Song 1'],
          'title': '',
          'listeners': 50,
          'bitrate': 128000,
        };

        final metadata = StationMetadata.fromJson(json);

        expect(metadata.isOnline, isFalse);
      });

      test('should return true from JSON with valid data', () {
        final json = {
          'history': ['Song 1'],
          'title': 'Current Song',
          'listeners': 50,
          'bitrate': 128000,
        };

        final metadata = StationMetadata.fromJson(json);

        expect(metadata.isOnline, isTrue);
      });
    });

    group('copyWith', () {
      test('should create new instance with updated values', () {
        final original = StationMetadata(
          history: ['Song 1'],
          title: 'Original',
          ulisteners: 100,
          listeners: 50,
          bitrate: 128000,
        );

        final copy = original.copyWith(title: 'Updated');

        expect(copy.title, 'Updated');
        expect(copy.history, ['Song 1']);
        expect(copy.listeners, 50);
      });

      test('should preserve original values when not updated', () {
        final original = StationMetadata(
          history: ['Song 1'],
          title: 'Title',
          art: 'https://art.com',
          ulisteners: 100,
          listeners: 50,
          bitrate: 128000,
        );

        final copy = original.copyWith();

        expect(copy.history, original.history);
        expect(copy.title, original.title);
        expect(copy.art, original.art);
        expect(copy.ulisteners, original.ulisteners);
        expect(copy.listeners, original.listeners);
        expect(copy.bitrate, original.bitrate);
      });
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        final m1 = StationMetadata(
          history: ['Song 1', 'Song 2'],
          title: 'Current',
          art: 'https://art.com',
          ulisteners: 100,
          listeners: 50,
          bitrate: 128000,
        );

        final m2 = StationMetadata(
          history: ['Song 1', 'Song 2'],
          title: 'Current',
          art: 'https://art.com',
          ulisteners: 100,
          listeners: 50,
          bitrate: 128000,
        );

        expect(m1 == m2, isTrue);
      });

      test('should not be equal when fields differ', () {
        final m1 = StationMetadata(
          history: ['Song 1'],
          title: 'Current',
          ulisteners: 100,
          listeners: 50,
          bitrate: 128000,
        );

        final m2 = StationMetadata(
          history: ['Song 1'],
          title: 'Different',
          ulisteners: 100,
          listeners: 50,
          bitrate: 128000,
        );

        expect(m1 == m2, isFalse);
      });

      test('should have consistent hashCode for equal objects', () {
        final m1 = StationMetadata(
          history: ['Song 1'],
          title: 'Current',
          ulisteners: 100,
          listeners: 50,
          bitrate: 128000,
        );

        final m2 = StationMetadata(
          history: ['Song 1'],
          title: 'Current',
          ulisteners: 100,
          listeners: 50,
          bitrate: 128000,
        );

        expect(m1.hashCode, equals(m2.hashCode));
      });
    });

    group('toString', () {
      test('should return correct string representation', () {
        final metadata = StationMetadata(
          history: ['Song 1'],
          title: 'Current',
          art: 'https://art.com',
          ulisteners: 100,
          listeners: 50,
          bitrate: 128000,
        );

        expect(
          metadata.toString(),
          'StationMetadata(history: [Song 1], title: Current, art: https://art.com, '
              'ulisteners: 100, listeners: 50, bitrate: 128000)',
        );
      });
    });
  });
}
