import '../../domain/entities/radio_station.dart';
import '../../domain/repositories/radio_station_repository.dart';

class GetRadioStationsUseCase {
  final RadioStationRepository repository;

  GetRadioStationsUseCase({required this.repository});

  Future<List<RadioStation>> call() {
    return repository.getRadioStations();
  }
}
