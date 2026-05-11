import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'domain/entities/radio_station.dart';
import 'infrastructure/datasources/radio_station_remote_datasource.dart';
import 'infrastructure/datasources/radio_station_local_datasource.dart';
import 'infrastructure/repositories/radio_station_repository_impl.dart';
import 'application/services/audio_player_service.dart';
import 'application/services/theme_notifier.dart';
import 'application/services/favorites_notifier.dart';
import 'presentation/pages/player_page.dart';
import 'presentation/pages/settings_page.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => AudioPlayerService()),
        ChangeNotifierProvider(create: (_) => FavoritesNotifier()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, _) {
          if (themeNotifier.isLoading) {
            return MaterialApp(
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          
          return MaterialApp(
            title: 'Radio Comunitaria Colombia',
            theme: themeNotifier.theme,
            home: const RadioStationListPage(),
          );
        },
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
      remoteDataSource: RadioStationRemoteDataSource(),
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

  void _openSettings() {
    final themeNotifier = context.read<ThemeNotifier>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          currentColor: themeNotifier.themeColor,
          onThemeChanged: (color) {
            themeNotifier.setThemeColor(color);
          },
        ),
      ),
    );
  }

  Widget _buildLogo(String? logo) {
    if (logo == null || logo.isEmpty) {
      return const Icon(Icons.radio, size: 40);
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

  @override
  Widget build(BuildContext context) {
    context.watch<AudioPlayerService>();
    context.watch<FavoritesNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Radio Comunitaria Colombia'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'settings') {
                _openSettings();
              } else if (value == 'refresh') {
                _refreshStations();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Recargar estaciones'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Configuración'),
                  ],
                ),
              ),
            ],
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

    return Consumer<FavoritesNotifier>(
      builder: (context, favoritesNotifier, _) {
        return ListView.builder(
          itemCount: _stations.length,
          itemBuilder: (context, index) {
            final station = _stations[index];
            final isFavorite = favoritesNotifier.isFavorite(station.name);
            debugPrint('Station: "${station.name}" -> isFavorite: $isFavorite, favorites: ${favoritesNotifier.favorites}');
            
            return ListTile(
              leading: _buildLogo(station.logo),
              title: Text(station.name),
              subtitle: Text(station.slogan ?? station.url),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      favoritesNotifier.toggleFavorite(station.name);
                    },
                  ),
                  const Icon(Icons.play_arrow),
                ],
              ),
              onTap: () => _openPlayer(station),
            );
          },
        );
      },
    );
  }
}