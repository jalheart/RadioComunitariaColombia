import '../../domain/entities/station_metadata.dart';
import '../../domain/repositories/radio_station_repository.dart';

class GetStationMetadataUseCase {
  final RadioStationRepository repository;

  GetStationMetadataUseCase({required this.repository});

  Future<StationMetadata?> call(String port) {
    return repository.getStationMetadata(port);
  }
}
