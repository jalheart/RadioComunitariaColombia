import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:rc/core/constants.dart';
import 'package:rc/infrastructure/datasources/station_metadata_remote_datasource.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockClient;
  late StationMetadataRemoteDataSource dataSource;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockClient = MockHttpClient();
    dataSource = StationMetadataRemoteDataSource(client: mockClient);
  });

  group('fetchMetadata', () {
    const port = '8286';
    late Uri expectedUri;

    setUp(() {
      expectedUri = Uri.parse('${ApiConstants.radioInfoEndpoint}$port');
    });

    test('should return StationMetadata when response is 200 with valid JSON',
        () async {
      const jsonResponse = '''
      {
        "history": ["Song 1", "Song 2"],
        "title": "Current Song",
        "art": "https://example.com/art.jpg",
        "ulisteners": 100,
        "listeners": 50,
        "bitrate": 128000
      }
      ''';

      when(() => mockClient.get(expectedUri)).thenAnswer(
        (_) async => http.Response(jsonResponse, 200),
      );

      final result = await dataSource.fetchMetadata(port);

      expect(result, isNotNull);
      expect(result!.history, ['Song 1', 'Song 2']);
      expect(result.title, 'Current Song');
      expect(result.art, 'https://example.com/art.jpg');
      expect(result.ulisteners, 100);
      expect(result.listeners, 50);
      expect(result.bitrate, 128000);
      expect(result.isOnline, isTrue);
    });

    test('should return null when response is 200 with invalid JSON', () async {
      when(() => mockClient.get(expectedUri)).thenAnswer(
        (_) async => http.Response('not valid json', 200),
      );

      final result = await dataSource.fetchMetadata(port);

      expect(result, isNull);
    });

    test('should return null when response status is 404', () async {
      when(() => mockClient.get(expectedUri)).thenAnswer(
        (_) async => http.Response('Not Found', 404),
      );

      final result = await dataSource.fetchMetadata(port);

      expect(result, isNull);
    });

    test('should return null on TimeoutException', () async {
      when(() => mockClient.get(expectedUri)).thenAnswer(
        (_) => Future.error(TimeoutException('timeout')),
      );

      final result = await dataSource.fetchMetadata(port);

      expect(result, isNull);
    });

    test('should return null on SocketException (network error)', () async {
      when(() => mockClient.get(expectedUri)).thenThrow(
        const SocketException('No internet connection'),
      );

      final result = await dataSource.fetchMetadata(port);

      expect(result, isNull);
    });

    test('should call correct endpoint with port', () async {
      when(() => mockClient.get(expectedUri)).thenAnswer(
        (_) async => http.Response('{"history":["Song"]}', 200),
      );

      await dataSource.fetchMetadata(port);

      verify(() => mockClient.get(expectedUri)).called(1);
    });
  });
}
