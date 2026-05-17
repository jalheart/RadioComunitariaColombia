import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rc/domain/entities/radio_station.dart';
import 'package:rc/infrastructure/datasources/radio_station_local_datasource.dart';

void main() {
  late RadioStationLocalDataSource dataSource;
  final station1 = RadioStation(
    name: 'Radio Colombia',
    url: 'https://radios.miservidor.cloud/cp/widgets/player/single/?p=8287',
    port: '8287',
    logo: 'https://logo.com/colombia.png',
    slogan: 'La voz de Colombia',
  );
  final station2 = RadioStation(
    name: 'Radio Bogotá',
    url: 'https://bogota.com/podcast?p=8080',
    port: '8080',
  );

  setUpAll(() {
    final tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    dataSource = RadioStationLocalDataSource();
    final box = await Hive.openBox('radio_stations');
    await box.clear();
  });

  tearDownAll(() async {
    final box = await Hive.openBox('radio_stations');
    await box.close();
    Hive.deleteBoxFromDisk('radio_stations');
  });

  group('getRadioStations', () {
    test('should return empty list when no stations are saved', () async {
      final result = await dataSource.getRadioStations();

      expect(result, isEmpty);
    });

    test('should return saved stations', () async {
      await dataSource.saveRadioStations([station1]);

      final result = await dataSource.getRadioStations();

      expect(result.length, 1);
      expect(result[0].name, 'Radio Colombia');
      expect(result[0].url,
          'https://radios.miservidor.cloud/cp/widgets/player/single/?p=8287');
      expect(result[0].port, '8287');
      expect(result[0].logo, 'https://logo.com/colombia.png');
      expect(result[0].slogan, 'La voz de Colombia');
    });

    test('should return all saved stations when multiple are stored',
        () async {
      await dataSource.saveRadioStations([station1, station2]);

      final result = await dataSource.getRadioStations();

      expect(result.length, 2);
      expect(result[0].name, 'Radio Colombia');
      expect(result[1].name, 'Radio Bogotá');
    });

    test('should ignore non-station keys in the box', () async {
      final box = await Hive.openBox('radio_stations');
      await box.put('unrelated_key', 'some value');
      await box.put('another_key', 12345);
      await dataSource.saveRadioStations([station1]);

      final result = await dataSource.getRadioStations();

      expect(result.length, 1);
      expect(result[0].name, 'Radio Colombia');
    });

    test('should return stations with all optional fields as null when absent',
        () async {
      final minimalStation = RadioStation(
        name: 'Minimal',
        url: 'https://radio.com',
      );
      await dataSource.saveRadioStations([minimalStation]);

      final result = await dataSource.getRadioStations();

      expect(result.length, 1);
      expect(result[0].port, isNull);
      expect(result[0].logo, isNull);
      expect(result[0].slogan, isNull);
    });
  });

  group('saveRadioStations', () {
    test('should persist stations to the box', () async {
      await dataSource.saveRadioStations([station1, station2]);

      final box = await Hive.openBox('radio_stations');
      final saved1 = box.get('station_0') as Map;
      final saved2 = box.get('station_1') as Map;

      expect(saved1['name'], 'Radio Colombia');
      expect(saved1['port'], '8287');
      expect(saved2['name'], 'Radio Bogotá');
      expect(saved2['port'], '8080');
    });

    test('should overwrite previous data when saving again', () async {
      await dataSource.saveRadioStations([station1]);
      await dataSource.saveRadioStations([station2]);

      final result = await dataSource.getRadioStations();

      expect(result.length, 1);
      expect(result[0].name, 'Radio Bogotá');
    });

    test('should save cache timestamp', () async {
      await dataSource.saveRadioStations([station1]);

      final box = await Hive.openBox('radio_stations');
      final timestamp = box.get('last_update');

      expect(timestamp, isNotNull);
      expect(timestamp, isA<int>());
    });
  });

  group('isCacheValid', () {
    test('should return false when no data has been saved', () async {
      final result = await dataSource.isCacheValid();
      expect(result, false);
    });

    test('should return true after saving stations', () async {
      await dataSource.saveRadioStations([station1]);

      final result = await dataSource.isCacheValid();

      expect(result, true);
    });

    test('should return false after cache is cleared', () async {
      await dataSource.saveRadioStations([station1]);
      await dataSource.clearCache();

      final result = await dataSource.isCacheValid();

      expect(result, false);
    });
  });

  group('clearCache', () {
    test('should remove all stations from the box', () async {
      await dataSource.saveRadioStations([station1, station2]);
      await dataSource.clearCache();

      final result = await dataSource.getRadioStations();

      expect(result, isEmpty);
    });

    test('should make isCacheValid return false', () async {
      await dataSource.saveRadioStations([station1]);
      await dataSource.clearCache();

      expect(await dataSource.isCacheValid(), false);
    });

    test('should work when box is already empty', () async {
      await dataSource.clearCache();

      final result = await dataSource.getRadioStations();

      expect(result, isEmpty);
    });
  });
}
