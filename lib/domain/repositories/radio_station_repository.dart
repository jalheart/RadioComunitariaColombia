import '../entities/radio_station.dart';
import '../entities/station_metadata.dart';

abstract class RadioStationRepository {
  Future<List<RadioStation>> getRadioStations();
  Future<StationMetadata?> getStationMetadata(String port);
}