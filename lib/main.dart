import 'dart:convert';
import 'package:flutter/material.dart';
import 'domain/entities/radio_station.dart';
import 'infrastructure/datasources/radio_station_remote_datasource.dart';
import 'infrastructure/datasources/radio_station_local_datasource.dart';
import 'infrastructure/repositories/radio_station_repository_impl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio Comunitaria Colombia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const RadioStationListPage(),
    );
  }
}

class RadioStationListPage extends StatefulWidget {
  const RadioStationListPage({super.key});

  @override
  State<RadioStationListPage> createState() => _RadioStationListPageState();
}

class _RadioStationListPageState extends State<RadioStationListPage> {
  late final RadioStationRepositoryImpl _repository;
  Future<List<RadioStation>>? _stationsFuture;

  @override
  void initState() {
    super.initState();
    _repository = RadioStationRepositoryImpl(
      remoteDataSource: RadioStationRemoteDataSource(
        corsProxy: 'https://corsproxy.io/?',
      ),
      localDataSource: RadioStationLocalDataSource(),
    );
    _loadStations();
  }

  void _loadStations() {
    setState(() {
      _stationsFuture = _repository.getRadioStations();
    });
  }

  void _refreshStations() async {
    setState(() {
      _stationsFuture = _repository.refreshRadioStations();
    });
  }

  Widget _buildLogo(String? logo) {
    if (logo == null || logo.isEmpty) {
      return const Icon(Icons.radio, size: 40);
    }

    if (logo.startsWith('data:image')) {
      try {
        final base64Data = logo.split(',').last;
        final imageBytes = base64Decode(base64Data);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            imageBytes,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.radio, size: 40),
          ),
        );
      } catch (_) {
        return const Icon(Icons.radio, size: 40);
      }
    }

    if (_isBase64(logo)) {
      try {
        final imageBytes = base64Decode(logo);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            imageBytes,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.radio, size: 40),
          ),
        );
      } catch (_) {
        return const Icon(Icons.radio, size: 40);
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        logo,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.radio, size: 40),
      ),
    );
  }

  bool _isBase64(String value) {
    try {
      final RegExp base64Regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
      return value.length % 4 == 0 && base64Regex.hasMatch(value);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radio Comunitaria Colombia'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStations,
            tooltip: 'Recargar estaciones',
          ),
        ],
      ),
      body: FutureBuilder<List<RadioStation>>(
        future: _stationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStations,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final stations = snapshot.data ?? [];

          if (stations.isEmpty) {
            return const Center(child: Text('No hay estaciones disponibles'));
          }

          return ListView.builder(
            itemCount: stations.length,
            itemBuilder: (context, index) {
              final station = stations[index];
              return ListTile(
                leading: _buildLogo(station.logo),
                title: Text(station.name),
                subtitle: Text(station.slogan ?? station.url),
                trailing: const Icon(Icons.play_arrow),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reproduciendo: ${station.name}')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}