import 'package:flutter/material.dart';

import '../../domain/entities/radio_station.dart';
import '../../domain/entities/station_metadata.dart';
import '../usecases/get_station_metadata_usecase.dart';

class AllStationsMetadataNotifier extends ChangeNotifier {
  final GetStationMetadataUseCase _getStationMetadataUseCase;
  final Map<String, StationMetadata?> _metadataMap = {};
  bool _isLoading = false;

  AllStationsMetadataNotifier({
    required GetStationMetadataUseCase getStationMetadataUseCase,
  }) : _getStationMetadataUseCase = getStationMetadataUseCase;

  bool get isLoading => _isLoading;

  StationMetadata? getMetadata(String stationName) {
    return _metadataMap[stationName];
  }

  bool? isOnline(String stationName) {
    final metadata = _metadataMap[stationName];
    if (metadata == null) return null;
    return metadata.isOnline;
  }

  Color getStatusColor(String stationName) {
    final online = isOnline(stationName);
    if (online == null) return Colors.grey;
    return online ? Colors.green : Colors.red;
  }

  Future<void> fetchAllMetadata(
    List<RadioStation> stations, {
    int? maxConcurrent,
  }) async {
    _isLoading = true;
    _metadataMap.clear();
    notifyListeners();

    final stationsWithPort = stations
        .where((s) => s.port != null && s.port!.isNotEmpty)
        .toList();

    if (maxConcurrent == null || maxConcurrent <= 0) {
      await Future.wait(
        stationsWithPort.map(_fetchMetadataForStation),
      );
    } else {
      for (var i = 0; i < stationsWithPort.length; i += maxConcurrent) {
        final batch = stationsWithPort.sublist(
          i,
          (i + maxConcurrent > stationsWithPort.length)
              ? stationsWithPort.length
              : i + maxConcurrent,
        );
        await Future.wait(batch.map(_fetchMetadataForStation));
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchMetadataForStation(RadioStation station) async {
    try {
      final metadata = await _getStationMetadataUseCase.call(station.port!);
      _metadataMap[station.name] = metadata;
    } catch (_) {
      _metadataMap[station.name] = null;
    }
  }

  void clear() {
    _metadataMap.clear();
    _isLoading = false;
    notifyListeners();
  }
}
