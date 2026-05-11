import '../../domain/entities/radio_station.dart';
import '../../domain/repositories/radio_station_repository.dart';
import '../datasources/radio_station_remote_datasource.dart';

class RadioStationRepositoryImpl implements RadioStationRepository {
  final RadioStationRemoteDataSource remoteDataSource;

  RadioStationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RadioStation>> getRadioStations() async {
    return await remoteDataSource.fetchRadioStations();
  }
}