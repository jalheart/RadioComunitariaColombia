import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rcc/application/usecases/get_station_metadata_usecase.dart';
import 'package:rcc/domain/entities/station_metadata.dart';
import 'package:rcc/domain/repositories/radio_station_repository.dart';

class MockRepository extends Mock implements RadioStationRepository {}

void main() {
  late MockRepository mockRepository;
  late GetStationMetadataUseCase useCase;

  setUp(() {
    mockRepository = MockRepository();
    useCase = GetStationMetadataUseCase(repository: mockRepository);
  });

  group('call', () {
    const port = '8286';

    test('should return StationMetadata when repository returns data', () async {
      final metadata = StationMetadata(
        history: ['Song 1'],
        title: 'Current Song',
        ulisteners: 100,
        listeners: 50,
        bitrate: 128000,
      );

      when(() => mockRepository.getStationMetadata(port)).thenAnswer(
        (_) async => metadata,
      );

      final result = await useCase(port);

      expect(result, equals(metadata));
      verify(() => mockRepository.getStationMetadata(port)).called(1);
    });

    test('should return null when repository returns null', () async {
      when(() => mockRepository.getStationMetadata(port)).thenAnswer(
        (_) async => null,
      );

      final result = await useCase(port);

      expect(result, isNull);
      verify(() => mockRepository.getStationMetadata(port)).called(1);
    });

    test('should propagate exception from repository', () async {
      when(() => mockRepository.getStationMetadata(port)).thenThrow(
        Exception('Network error'),
      );

      expect(
        () => useCase(port),
        throwsA(isA<Exception>()),
      );
    });
  });
}
