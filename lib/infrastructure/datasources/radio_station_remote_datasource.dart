import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../../domain/entities/radio_station.dart';

class RadioStationRemoteDataSource {
  final http.Client client;

  RadioStationRemoteDataSource({http.Client? client})
      : client = client ?? http.Client();

  Future<List<RadioStation>> fetchRadioStations() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.backendUrl}/stations'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map((json) => RadioStation(
                name: json['name'] as String,
                url: json['url'] as String,
              ))
          .toList();
    } else {
      throw Exception('Failed to load radio stations: ${response.statusCode}');
    }
  }
}