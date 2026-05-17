import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import '../../domain/entities/station_metadata.dart';

class StationMetadataRemoteDataSource {
  final http.Client client;

  StationMetadataRemoteDataSource({
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<StationMetadata?> fetchMetadata(String port) async {
    try {
      final uri = Uri.parse('${ApiConstants.radioInfoEndpoint}$port');
      final response = await client
          .get(uri)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return null;

      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      return StationMetadata.fromJson(jsonMap);
    } on TimeoutException {
      return null;
    } on SocketException {
      return null;
    } on HttpException {
      return null;
    } on FormatException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
