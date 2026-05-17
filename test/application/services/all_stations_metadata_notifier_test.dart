import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rcc/application/services/all_stations_metadata_notifier.dart';
import 'package:rcc/application/usecases/get_station_metadata_usecase.dart';
import 'package:rcc/domain/entities/radio_station.dart';
import 'package:rcc/domain/entities/station_metadata.dart';

class MockGetStationMetadataUseCase extends Mock
    implements GetStationMetadataUseCase {}

void main() {
  late AllStationsMetadataNotifier notifier;
  late MockGetStationMetadataUseCase mockUseCase;

  final station1 = RadioStation(
    name: 'Radio Uno',
    url: 'https://example.com/1',
    port: '8001',
  );
  final station2 = RadioStation(
    name: 'Radio Dos',
    url: 'https://example.com/2',
    port: '8002',
  );
  final stationNoPort = RadioStation(
    name: 'Radio Sin Puerto',
    url: 'https://example.com/3',
  );
  final stationEmptyPort = RadioStation(
    name: 'Radio Puerto Vacio',
    url: 'https://example.com/4',
    port: '',
  );

  final metadata1 = StationMetadata(
    history: ['Song 1'],
    title: 'Radio Uno Title',
    bitrate: 128,
    listeners: 10,
    ulisteners: 5,
  );
  final metadata2 = StationMetadata(
    history: ['Song 2'],
    title: 'Radio Dos Title',
    bitrate: 192,
    listeners: 20,
    ulisteners: 15,
  );

  setUp(() {
    mockUseCase = MockGetStationMetadataUseCase();
    notifier = AllStationsMetadataNotifier(
      getStationMetadataUseCase: mockUseCase,
    );
  });

  group('initial state', () {
    test('should have correct initial values', () {
      expect(notifier.isLoading, false);
      expect(notifier.getMetadata('any'), isNull);
      expect(notifier.isOnline('any'), isNull);
      expect(notifier.getStatusColor('any'), Colors.grey);
    });
  });

  group('clear', () {
    test('should reset state to initial', () async {
      when(() => mockUseCase.call('8001')).thenAnswer(
        (_) async => metadata1,
      );

      await notifier.fetchAllMetadata([station1]);
      notifier.clear();

      expect(notifier.isLoading, false);
      expect(notifier.getMetadata('Radio Uno'), isNull);
      expect(notifier.isOnline('Radio Uno'), isNull);
      expect(notifier.getStatusColor('Radio Uno'), Colors.grey);
    });
  });

  group('fetchAllMetadata', () {
    test('should execute all calls in parallel and store results', () async {
      when(() => mockUseCase.call('8001')).thenAnswer(
        (_) async => metadata1,
      );
      when(() => mockUseCase.call('8002')).thenAnswer(
        (_) async => metadata2,
      );

      await notifier.fetchAllMetadata([station1, station2]);

      expect(notifier.getMetadata('Radio Uno'), metadata1);
      expect(notifier.getMetadata('Radio Dos'), metadata2);
      expect(notifier.isOnline('Radio Uno'), true);
      expect(notifier.isOnline('Radio Dos'), true);
      expect(notifier.isLoading, false);
    });

    test('should skip stations without port or with empty port', () async {
      when(() => mockUseCase.call('8001')).thenAnswer(
        (_) async => metadata1,
      );

      await notifier.fetchAllMetadata([
        station1,
        stationNoPort,
        stationEmptyPort,
      ]);

      expect(notifier.getMetadata('Radio Uno'), metadata1);
      expect(notifier.getMetadata('Radio Sin Puerto'), isNull);
      expect(notifier.getMetadata('Radio Puerto Vacio'), isNull);
    });

    test('should handle partial failures without breaking other calls',
        () async {
      when(() => mockUseCase.call('8001')).thenAnswer(
        (_) async => metadata1,
      );
      when(() => mockUseCase.call('8002')).thenThrow(
        Exception('Network error'),
      );

      await notifier.fetchAllMetadata([station1, station2]);

      expect(notifier.getMetadata('Radio Uno'), metadata1);
      expect(notifier.getMetadata('Radio Dos'), isNull);
      expect(notifier.isOnline('Radio Dos'), isNull);
      expect(notifier.getStatusColor('Radio Dos'), Colors.grey);
      expect(notifier.isLoading, false);
    });

    test('should handle all stations failing', () async {
      when(() => mockUseCase.call(any())).thenThrow(
        Exception('Network error'),
      );

      await notifier.fetchAllMetadata([station1, station2]);

      expect(notifier.getMetadata('Radio Uno'), isNull);
      expect(notifier.getMetadata('Radio Dos'), isNull);
      expect(notifier.isLoading, false);
    });

    test('should set isLoading during execution', () async {
      late bool loadingDuringExecution;
      when(() => mockUseCase.call('8001')).thenAnswer(
        (_) async {
          loadingDuringExecution = notifier.isLoading;
          return metadata1;
        },
      );

      await notifier.fetchAllMetadata([station1]);

      expect(loadingDuringExecution, true);
      expect(notifier.isLoading, false);
    });

    test('should clear previous metadata before fetching', () async {
      when(() => mockUseCase.call('8001')).thenAnswer(
        (_) async => metadata1,
      );
      when(() => mockUseCase.call('8002')).thenAnswer(
        (_) async => metadata2,
      );

      await notifier.fetchAllMetadata([station1]);
      await notifier.fetchAllMetadata([station2]);

      expect(notifier.getMetadata('Radio Uno'), isNull);
      expect(notifier.getMetadata('Radio Dos'), metadata2);
    });

    test('should handle empty stations list', () async {
      await notifier.fetchAllMetadata([]);

      expect(notifier.isLoading, false);
    });

    group('maxConcurrent', () {
      test('should process in batches when maxConcurrent is set', () async {
        final station3 = RadioStation(
          name: 'Radio Tres',
          url: 'https://example.com/3',
          port: '8003',
        );
        final metadata3 = StationMetadata(
          history: ['Song 3'],
          title: 'Radio Tres Title',
          bitrate: 64,
          listeners: 5,
          ulisteners: 2,
        );

        when(() => mockUseCase.call('8001')).thenAnswer(
          (_) async => metadata1,
        );
        when(() => mockUseCase.call('8002')).thenAnswer(
          (_) async => metadata2,
        );
        when(() => mockUseCase.call('8003')).thenAnswer(
          (_) async => metadata3,
        );

        await notifier.fetchAllMetadata(
          [station1, station2, station3],
          maxConcurrent: 2,
        );

        expect(notifier.getMetadata('Radio Uno'), metadata1);
        expect(notifier.getMetadata('Radio Dos'), metadata2);
        expect(notifier.getMetadata('Radio Tres'), metadata3);
        expect(notifier.isLoading, false);
      });

      test('should process sequentially when maxConcurrent is 1', () async {
        final callOrder = <String>[];
        when(() => mockUseCase.call('8001')).thenAnswer(
          (_) async {
            callOrder.add('start1');
            await Future.delayed(const Duration(milliseconds: 50));
            callOrder.add('end1');
            return metadata1;
          },
        );
        when(() => mockUseCase.call('8002')).thenAnswer(
          (_) async {
            callOrder.add('start2');
            return metadata2;
          },
        );

        await notifier.fetchAllMetadata(
          [station1, station2],
          maxConcurrent: 1,
        );

        expect(callOrder, ['start1', 'end1', 'start2']);
        expect(notifier.getMetadata('Radio Uno'), metadata1);
        expect(notifier.getMetadata('Radio Dos'), metadata2);
      });

      test('should treat maxConcurrent <= 0 as no limit', () async {
        final station3 = RadioStation(
          name: 'Radio Tres',
          url: 'https://example.com/3',
          port: '8003',
        );

        when(() => mockUseCase.call(any())).thenAnswer(
          (_) async => metadata1,
        );

        await notifier.fetchAllMetadata(
          [station1, station2, station3],
          maxConcurrent: 0,
        );

        expect(notifier.getMetadata('Radio Uno'), metadata1);
        expect(notifier.getMetadata('Radio Dos'), metadata1);
        expect(notifier.getMetadata('Radio Tres'), metadata1);
        expect(notifier.isLoading, false);
      });
    });
  });
}
