import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'domain/entities/radio_station.dart';
import 'infrastructure/datasources/radio_station_remote_datasource.dart';
import 'infrastructure/datasources/radio_station_local_datasource.dart';
import 'infrastructure/repositories/radio_station_repository_impl.dart';
import 'application/services/audio_player_service.dart';
import 'presentation/pages/player_page.dart';
import 'presentation/widgets/mini_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AudioPlayerService(),
      child: MaterialApp(
        title: 'Radio Comunitaria Colombia',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const RadioStationListPage(),
      ),
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
  List<RadioStation> _stations = [];
  bool _isLoading = true;
  String? _error;

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

  Future<void> _loadStations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final stations = await _repository.getRadioStations();
      if (mounted) {
        setState(() {
          _stations = stations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshStations() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final stations = await _repository.refreshRadioStations();
      if (mounted) {
        setState(() {
          _stations = stations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _openPlayer(RadioStation station) async {
    final audioService = context.read<AudioPlayerService>();
    await audioService.play(station);
    
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerPage(
          station: station,
          onMinimize: () {
            audioService.minimize();
            Navigator.pop(context);
          },
          onClose: () {
            audioService.stop();
            Navigator.pop(context);
          },
        ),
      ),
    );
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
    final audioService = context.watch<AudioPlayerService>();

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
      body: _buildBody(),
      bottomNavigationBar: audioService.hasStation 
          ? MiniPlayer(
              audioService: audioService,
              onTap: () => _openPlayer(audioService.currentStation!),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStations,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_stations.isEmpty) {
      return const Center(child: Text('No hay estaciones disponibles'));
    }

    return ListView.builder(
      itemCount: _stations.length,
      itemBuilder: (context, index) {
        final station = _stations[index];
        return ListTile(
          leading: _buildLogo(station.logo),
          title: Text(station.name),
          subtitle: Text(station.slogan ?? station.url),
          trailing: const Icon(Icons.play_arrow),
          onTap: () => _openPlayer(station),
        );
      },
    );
  }
}