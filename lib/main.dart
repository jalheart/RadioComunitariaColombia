import 'package:flutter/material.dart';
import 'domain/entities/radio_station.dart';
import 'infrastructure/datasources/radio_station_remote_datasource.dart';
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
      remoteDataSource: RadioStationRemoteDataSource(),
    );
    _loadStations();
  }

  void _loadStations() {
    setState(() {
      _stationsFuture = _repository.getRadioStations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radio Comunitaria Colombia'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                leading: const Icon(Icons.radio),
                title: Text(station.name),
                subtitle: Text(station.url),
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