import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:rc/core/constants.dart';
import 'package:rc/infrastructure/datasources/radio_station_remote_datasource.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockClient;
  late RadioStationRemoteDataSource dataSource;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockClient = MockHttpClient();
    dataSource = RadioStationRemoteDataSource(client: mockClient);
  });

  group('fetchRadioStations', () {
    test('should return list of RadioStation when response is 200', () async {
      const jsonResponse = '[{"name":"Radio Colombia","url":"https://radio.com"},{"name":"Radio Bogotá","url":"https://bogota.com"}]';

      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonResponse, 200),
      );

      final result = await dataSource.fetchRadioStations();

      expect(result.length, 2);
      expect(result[0].name, 'Radio Colombia');
      expect(result[0].url, 'https://radio.com');
      expect(result[1].name, 'Radio Bogotá');
      expect(result[1].url, 'https://bogota.com');
    });

    test('should call correct endpoint', () async {
      const jsonResponse = '[]';

      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonResponse, 200),
      );

      await dataSource.fetchRadioStations();

      verify(() => mockClient.get(
            Uri.parse('${ApiConstants.backendUrl}/stations'),
          )).called(1);
    });

    test('should throw Exception when response is not 200', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response('Error', 500),
      );

      expect(
        () => dataSource.fetchRadioStations(),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw Exception with status code in message', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response('Error', 404),
      );

      try {
        await dataSource.fetchRadioStations();
      } catch (e) {
        expect(e.toString(), contains('404'));
      }
    });
  });
}