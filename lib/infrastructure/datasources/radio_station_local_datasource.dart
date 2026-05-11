import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/radio_station.dart';

class RadioStationLocalDataSource {
  static const String _boxName = 'radio_stations';
  static const String _timestampKey = 'last_update';
  static const Duration _cacheExpiration = Duration(hours: 1);

  Box? _box;
  int? _cacheTimestamp;

  Future<Box> get _storage async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox(_boxName);
    return _box!;
  }

  Future<List<RadioStation>> getRadioStations() async {
    try {
      final box = await _storage;
      final stations = <RadioStation>[];
      
      for (var i = 0; i < box.length; i++) {
        final key = box.keyAt(i);
        if (key is String && key.startsWith('station_')) {
          final data = box.get(key);
          if (data != null) {
            stations.add(_fromMap(Map<String, dynamic>.from(data)));
          }
        }
      }
      
      return stations;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRadioStations(List<RadioStation> stations) async {
    try {
      final box = await _storage;
      
      await box.clear();
      
      for (var i = 0; i < stations.length; i++) {
        await box.put('station_$i', _toMap(stations[i]));
      }
      
      _cacheTimestamp = DateTime.now().millisecondsSinceEpoch;
      await box.put(_timestampKey, _cacheTimestamp);
    } catch (_) {}
  }

  Future<bool> isCacheValid() async {
    try {
      final box = await _storage;
      final timestamp = box.get(_timestampKey);
      
      if (timestamp == null) return false;
      
      _cacheTimestamp = timestamp as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(_cacheTimestamp!);
      return DateTime.now().difference(cacheTime) < _cacheExpiration;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearCache() async {
    try {
      final box = await _storage;
      await box.clear();
      _cacheTimestamp = null;
    } catch (_) {}
  }

  Map<String, dynamic> _toMap(RadioStation station) {
    return {
      'name': station.name,
      'url': station.url,
      'port': station.port,
      'logo': station.logo,
      'slogan': station.slogan,
    };
  }

  RadioStation _fromMap(Map<String, dynamic> map) {
    return RadioStation(
      name: map['name'] as String,
      url: map['url'] as String,
      port: map['port'] as String?,
      logo: map['logo'] as String?,
      slogan: map['slogan'] as String?,
    );
  }
}