import '../../domain/entities/radio_station.dart';
import '../../domain/entities/station_metadata.dart';
import '../../domain/repositories/radio_station_repository.dart';
import '../datasources/radio_station_local_datasource.dart';
import '../datasources/radio_station_remote_datasource.dart';
import '../datasources/station_metadata_remote_datasource.dart';

class RadioStationRepositoryImpl implements RadioStationRepository {
  final RadioStationRemoteDataSource remoteDataSource;
  final RadioStationLocalDataSource localDataSource;
  final StationMetadataRemoteDataSource metadataDataSource;

  RadioStationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.metadataDataSource,
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

  @override
  Future<List<RadioStation>> refreshRadioStations() async {
    final remoteStations = await remoteDataSource.fetchRadioStations();
    await localDataSource.saveRadioStations(remoteStations);
    return remoteStations;
  }

  @override
  Future<StationMetadata?> getStationMetadata(String port) async {
    return metadataDataSource.fetchMetadata(port);
  }

  @override
  Future<void> clearCache() async {
    await localDataSource.clearCache();
  }
}