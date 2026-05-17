import '../entities/radio_station.dart';
import '../entities/station_metadata.dart';

abstract class RadioStationRepository {
  Future<List<RadioStation>> getRadioStations();
  Future<List<RadioStation>> refreshRadioStations();
  Future<StationMetadata?> getStationMetadata(String port);
  Future<void> clearCache();
}