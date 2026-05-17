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
      const jsonResponse = '[{"name":"Radio Colombia","url":"https://radios.miservidor.cloud/cp/widgets/player/single/?p=8287"},{"name":"Radio Bogotá","url":"https://bogota.com/podcast?p=8080"}]';

      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonResponse, 200),
      );

      final result = await dataSource.fetchRadioStations();

      expect(result.length, 2);
      expect(result[0].name, 'Radio Colombia');
      expect(result[0].url, 'https://radios.miservidor.cloud/cp/widgets/player/single/?p=8287');
      expect(result[0].port, '8287');
      expect(result[1].name, 'Radio Bogotá');
      expect(result[1].url, 'https://bogota.com/podcast?p=8080');
      expect(result[1].port, '8080');
    });

    test('should call correct endpoint', () async {
      const jsonResponse = '[]';

      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonResponse, 200),
      );

      await dataSource.fetchRadioStations();

      verify(() => mockClient.get(
            Uri.parse(ApiConstants.backendUrl),
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

    test('should return null port when URL has no p parameter', () async {
      const jsonResponse = '[{"name":"Radio Sin Puerto","url":"https://radio.com/stream"}]';

      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonResponse, 200),
      );

      final result = await dataSource.fetchRadioStations();

      expect(result[0].port, isNull);
    });

    test('should return logo from JSON when present', () async {
      const jsonResponse = '[{"name":"Radio Colombia","url":"https://radio.com","logo":"data:image/jpeg;base64,iVBORw0KGgoAAAANSUhEUgAAA=="}]';

      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonResponse, 200),
      );

      final result = await dataSource.fetchRadioStations();

      expect(result[0].logo, 'data:image/jpeg;base64,iVBORw0KGgoAAAANSUhEUgAAA==');
    });

    test('should return null logo when not present in JSON', () async {
      const jsonResponse = '[{"name":"Radio Colombia","url":"https://radio.com"}]';

      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonResponse, 200),
      );

      final result = await dataSource.fetchRadioStations();

      expect(result[0].logo, isNull);
    });

    test('should prioritize json int port over extracted url port', () async {
      const jsonResponse =
          '[{"name":"Radio Colombia","url":"https://radios.miservidor.cloud/cp/widgets/player/single/?p=8287","port":9999}]';

      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonResponse, 200),
      );

      final result = await dataSource.fetchRadioStations();

      expect(result[0].port, '9999');
    });

    test('should fallback to extracted url port when json port is null', () async {
      const jsonResponse =
          '[{"name":"Radio Colombia","url":"https://radios.miservidor.cloud/cp/widgets/player/single/?p=8287"}]';

      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonResponse, 200),
      );

      final result = await dataSource.fetchRadioStations();

      expect(result[0].port, '8287');
    });
  });
}