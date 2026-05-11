import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/radio_station.dart';

class RadioStationLocalDataSource {
  static const String _cacheKey = 'radio_stations_cache';
  static const String _cacheTimestampKey = 'radio_stations_timestamp';
  static const Duration _cacheExpiration = Duration(hours: 1);

  Future<List<RadioStation>> getRadioStations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => _fromJson(json)).toList();
      }
    } catch (_) {}
    
    return [];
  }

  Future<void> saveRadioStations(List<RadioStation> stations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = stations.map((s) => _toJson(s)).toList();
      await prefs.setString(_cacheKey, json.encode(jsonList));
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);
      
      if (timestamp == null) return false;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime.now().difference(cacheTime) < _cacheExpiration;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
    } catch (_) {}
  }

  Map<String, dynamic> _toJson(RadioStation station) {
    return {
      'name': station.name,
      'url': station.url,
      'port': station.port,
      'logo': station.logo,
      'slogan': station.slogan,
    };
  }

  RadioStation _fromJson(Map<String, dynamic> json) {
    return RadioStation(
      name: json['name'] as String,
      url: json['url'] as String,
      port: json['port'] as String?,
      logo: json['logo'] as String?,
      slogan: json['slogan'] as String?,
    );
  }
}