import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rc/domain/entities/radio_station.dart';
import 'package:rc/domain/entities/station_metadata.dart';
import 'package:rc/infrastructure/datasources/radio_station_local_datasource.dart';
import 'package:rc/infrastructure/datasources/radio_station_remote_datasource.dart';
import 'package:rc/infrastructure/datasources/station_metadata_remote_datasource.dart';
import 'package:rc/infrastructure/repositories/radio_station_repository_impl.dart';

class MockRemoteDataSource extends Mock implements RadioStationRemoteDataSource {}

class MockLocalDataSource extends Mock implements RadioStationLocalDataSource {}

class MockMetadataDataSource extends Mock
    implements StationMetadataRemoteDataSource {}

void main() {
  late RadioStationRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;
  late MockMetadataDataSource mockMetadata;

  final station = RadioStation(
    name: 'Radio Colombia',
    url: 'https://radios.miservidor.cloud/cp/widgets/player/single/?p=8287',
    port: '8287',
  );

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    mockMetadata = MockMetadataDataSource();
    repository = RadioStationRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
      metadataDataSource: mockMetadata,
    );
  });

  group('getRadioStations', () {
    test('should return cached stations when cache is valid and not empty',
        () async {
      when(() => mockLocal.isCacheValid()).thenAnswer((_) async => true);
      when(() => mockLocal.getRadioStations())
          .thenAnswer((_) async => [station]);

      final result = await repository.getRadioStations();

      expect(result, [station]);
      verify(() => mockLocal.isCacheValid()).called(1);
      verify(() => mockLocal.getRadioStations()).called(1);
      verifyNever(() => mockRemote.fetchRadioStations());
      verifyNever(() => mockLocal.saveRadioStations(any()));
    });

    test('should fetch remote when cache is valid but empty', () async {
      when(() => mockLocal.isCacheValid()).thenAnswer((_) async => true);
      when(() => mockLocal.getRadioStations()).thenAnswer((_) async => []);
      when(() => mockRemote.fetchRadioStations())
          .thenAnswer((_) async => [station]);
      when(() => mockLocal.saveRadioStations(any()))
          .thenAnswer((_) async {});

      final result = await repository.getRadioStations();

      expect(result, [station]);
      verify(() => mockRemote.fetchRadioStations()).called(1);
      verify(() => mockLocal.saveRadioStations([station])).called(1);
    });

    test('should fetch remote when cache is invalid', () async {
      when(() => mockLocal.isCacheValid()).thenAnswer((_) async => false);
      when(() => mockRemote.fetchRadioStations())
          .thenAnswer((_) async => [station]);
      when(() => mockLocal.saveRadioStations(any()))
          .thenAnswer((_) async {});

      final result = await repository.getRadioStations();

      expect(result, [station]);
      verify(() => mockRemote.fetchRadioStations()).called(1);
      verify(() => mockLocal.saveRadioStations([station])).called(1);
      verifyNever(() => mockLocal.getRadioStations());
    });

    test('should save remote stations to cache after fetch', () async {
      when(() => mockLocal.isCacheValid()).thenAnswer((_) async => false);
      when(() => mockRemote.fetchRadioStations())
          .thenAnswer((_) async => [station]);
      when(() => mockLocal.saveRadioStations(any()))
          .thenAnswer((_) async {});

      await repository.getRadioStations();

      verify(() => mockLocal.saveRadioStations([station])).called(1);
    });
  });

  group('refreshRadioStations', () {
    test('should always fetch from remote and save to cache', () async {
      when(() => mockRemote.fetchRadioStations())
          .thenAnswer((_) async => [station]);
      when(() => mockLocal.saveRadioStations(any()))
          .thenAnswer((_) async {});

      final result = await repository.refreshRadioStations();

      expect(result, [station]);
      verify(() => mockRemote.fetchRadioStations()).called(1);
      verify(() => mockLocal.saveRadioStations([station])).called(1);
    });

    test('should not check cache validity', () async {
      when(() => mockRemote.fetchRadioStations())
          .thenAnswer((_) async => [station]);
      when(() => mockLocal.saveRadioStations(any()))
          .thenAnswer((_) async {});

      await repository.refreshRadioStations();

      verifyNever(() => mockLocal.isCacheValid());
      verifyNever(() => mockLocal.getRadioStations());
    });
  });

  group('getStationMetadata', () {
    test('should delegate to metadataDataSource', () async {
      const port = '8287';
      final metadata = StationMetadata(
        history: ['Song 1'],
        title: 'Current Song',
        ulisteners: 100,
        listeners: 50,
        bitrate: 128000,
      );
      when(() => mockMetadata.fetchMetadata(port))
          .thenAnswer((_) async => metadata);

      final result = await repository.getStationMetadata(port);

      expect(result, metadata);
      verify(() => mockMetadata.fetchMetadata(port)).called(1);
    });

    test('should return null when metadataDataSource returns null', () async {
      const port = '8287';
      when(() => mockMetadata.fetchMetadata(port))
          .thenAnswer((_) async => null);

      final result = await repository.getStationMetadata(port);

      expect(result, isNull);
    });
  });

  group('clearCache', () {
    test('should delegate to localDataSource.clearCache', () async {
      when(() => mockLocal.clearCache()).thenAnswer((_) async {});

      await repository.clearCache();

      verify(() => mockLocal.clearCache()).called(1);
    });
  });
}
