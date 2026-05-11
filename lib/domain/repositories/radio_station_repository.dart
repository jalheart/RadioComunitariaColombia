import '../entities/radio_station.dart';

abstract class RadioStationRepository {
  Future<List<RadioStation>> getRadioStations();
}