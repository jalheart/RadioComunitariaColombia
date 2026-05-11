import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../../core/constants.dart';
import '../../domain/entities/radio_station.dart';

class RadioStationRemoteDataSource {
  final http.Client client;
  final String? corsProxy;

  RadioStationRemoteDataSource({
    http.Client? client,
    this.corsProxy,
  }) : client = client ?? http.Client();

  static const Map<String, String> _headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
  };

  Future<List<RadioStation>> fetchRadioStations() async {
    final response = await client.get(Uri.parse(ApiConstants.backendUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      
      final stations = <RadioStation>[];
      for (final json in jsonList) {
        final url = json['url'] as String;
        
        String? logo = json['logo'] as String?;
        if (logo == null || logo.isEmpty) {
          logo = await _extractLogo(url);
        }
        
        stations.add(RadioStation(
          name: json['name'] as String,
          url: url,
          port: _extractPort(url),
          logo: logo,
          slogan: json['slogan'] as String?,
        ));
      }
      
      return stations;
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

  Future<String?> _extractLogo(String stationUrl) async {
    try {
      final urlToFetch = corsProxy != null 
          ? '$corsProxy${Uri.encodeComponent(stationUrl)}' 
          : stationUrl;
      
      final response = await client.get(
        Uri.parse(urlToFetch),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final artDiv = document.getElementById('art');
        
        if (artDiv != null) {
          final imgElement = artDiv.querySelector('img');
          if (imgElement != null) {
            return imgElement.attributes['src'];
          }
        }
      }
    } catch (_) {}
    
    return null;
  }
}