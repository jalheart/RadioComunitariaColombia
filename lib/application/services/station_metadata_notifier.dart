import 'package:flutter/material.dart';

import '../../domain/entities/station_metadata.dart';
import '../usecases/get_station_metadata_usecase.dart';

class StationMetadataNotifier extends ChangeNotifier {
  final GetStationMetadataUseCase _getStationMetadataUseCase;

  StationMetadata? _metadata;
  bool _isLoading = false;
  String? _error;

  StationMetadataNotifier({required GetStationMetadataUseCase getStationMetadataUseCase})
      : _getStationMetadataUseCase = getStationMetadataUseCase;

  StationMetadata? get metadata => _metadata;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMetadata(String port) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _metadata = await _getStationMetadataUseCase.call(port);
    } catch (e) {
      _metadata = null;
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _metadata = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
