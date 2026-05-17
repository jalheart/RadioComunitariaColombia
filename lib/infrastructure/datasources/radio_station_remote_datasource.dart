import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../../domain/entities/radio_station.dart';

class RadioStationRemoteDataSource {
  final http.Client client;

  RadioStationRemoteDataSource({
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<List<RadioStation>> fetchRadioStations() async {
    final response = await client.get(Uri.parse(ApiConstants.backendUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      
      return jsonList.map((json) {
        final url = json['url'] as String;
        return RadioStation(
          name: json['name'] as String,
          url: url,
          port: (json['port']?.toString()) ?? _extractPort(url),
          logo: json['logo'] as String?,
          slogan: json['slogan'] as String?,
        );
      }).toList();
    } else {
      throw Exception('Failed to load radio stations: ${response.statusCode}');
    }
  }

  String? _extractPort(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['p'];
    } catch (_) {
      return null;
    }
  }
}