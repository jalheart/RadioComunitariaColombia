import '../../domain/entities/radio_station.dart';
import '../../domain/repositories/radio_station_repository.dart';
import '../datasources/radio_station_remote_datasource.dart';
import '../datasources/radio_station_local_datasource.dart';

class RadioStationRepositoryImpl implements RadioStationRepository {
  final RadioStationRemoteDataSource remoteDataSource;
  final RadioStationLocalDataSource localDataSource;

  RadioStationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<RadioStation>> getRadioStations() async {
    final isCacheValid = await localDataSource.isCacheValid();
    
    if (isCacheValid) {
      final cachedStations = await localDataSource.getRadioStations();
      if (cachedStations.isNotEmpty) {
        return cachedStations;
      }
    }
    
    final remoteStations = await remoteDataSource.fetchRadioStations();
    await localDataSource.saveRadioStations(remoteStations);
    
    return remoteStations;
  }

  Future<List<RadioStation>> refreshRadioStations() async {
    final remoteStations = await remoteDataSource.fetchRadioStations();
    await localDataSource.saveRadioStations(remoteStations);
    return remoteStations;
  }

  Future<void> clearCache() async {
    await localDataSource.clearCache();
  }
}