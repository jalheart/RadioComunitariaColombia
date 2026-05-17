import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/radio_station.dart';
import '../../infrastructure/datasources/radio_station_remote_datasource.dart';
import '../../infrastructure/datasources/radio_station_local_datasource.dart';
import '../../infrastructure/datasources/station_metadata_remote_datasource.dart';
import '../../infrastructure/repositories/radio_station_repository_impl.dart';
import '../../application/services/audio_player_service.dart';
import '../../application/services/favorites_notifier.dart';
import '../../application/services/all_stations_metadata_notifier.dart';
import '../../application/services/theme_notifier.dart';
import 'player_page.dart';
import 'settings_page.dart';
import '../widgets/mini_player.dart';
import '../widgets/station_logo.dart';

class RadioStationListPage extends StatefulWidget {
  const RadioStationListPage({
    super.key,
    RadioStationRepositoryImpl? repository,
  }) : _repository = repository;

  final RadioStationRepositoryImpl? _repository;

  @override
  State<RadioStationListPage> createState() => _RadioStationListPageState();
}

class _RadioStationListPageState extends State<RadioStationListPage> {
  late final RadioStationRepositoryImpl _repository;
  List<RadioStation> _stations = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _filterOnlineOnly = false;

  @override
  void initState() {
    super.initState();
    _repository = widget._repository ??
        RadioStationRepositoryImpl(
          remoteDataSource: RadioStationRemoteDataSource(),
          localDataSource: RadioStationLocalDataSource(),
          metadataDataSource: StationMetadataRemoteDataSource(),
        );
    _loadStations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        context.read<AllStationsMetadataNotifier>().fetchAllMetadata(stations);
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
        context.read<AllStationsMetadataNotifier>().fetchAllMetadata(stations);
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

  void _openPlayer(RadioStation station) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerPage(
          station: station,
          onMinimize: () {
            final audioService = context.read<AudioPlayerService>();
            audioService.minimize();
            audioService.play(station);
            Navigator.pop(context);
          },
          onClose: () {
            final audioService = context.read<AudioPlayerService>();
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
          isDarkMode: themeNotifier.isDarkMode,
          onBrightnessChanged: (isDark) {
            themeNotifier.setBrightness(isDark);
          },
        ),
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
      bottomNavigationBar: Consumer2<AudioPlayerService, AllStationsMetadataNotifier>(
        builder: (context, audioService, metadataNotifier, _) {
          if (!audioService.hasStation) return const SizedBox.shrink();
          final station = audioService.currentStation!;
          final isOnline = metadataNotifier.isOnline(station.name);
          if (isOnline != true) return const SizedBox.shrink();
          return MiniPlayer(
            audioService: audioService,
            onTap: () => _openPlayer(audioService.currentStation!),
          );
        },
      ),
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar emisora...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: 'Solo online',
                child: Switch(
                  value: _filterOnlineOnly,
                  thumbIcon: WidgetStatePropertyAll(
                    Icon(_filterOnlineOnly ? Icons.signal_wifi_4_bar : Icons.signal_wifi_off, size: 16),
                  ),
                  onChanged: (value) => setState(() => _filterOnlineOnly = value),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<FavoritesNotifier>(
            builder: (context, favoritesNotifier, _) {
              final metadataNotifier = context.watch<AllStationsMetadataNotifier>();

              final filtered = _stations.where((s) {
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  if (!s.name.toLowerCase().contains(q) &&
                      !(s.slogan?.toLowerCase().contains(q) ?? false)) {
                    return false;
                  }
                }
                if (_filterOnlineOnly) {
                  if (metadataNotifier.isOnline(s.name) != true) return false;
                }
                return true;
              }).toList();

              final favorites = filtered.where((s) => favoritesNotifier.isFavorite(s.name)).toList()
                ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
              final nonFavorites = filtered.where((s) => !favoritesNotifier.isFavorite(s.name)).toList()
                ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
              final sortedStations = [...favorites, ...nonFavorites];

              if (sortedStations.isEmpty) {
                return const Center(child: Text('No se encontraron emisoras'));
              }

              return ListView.builder(
                itemCount: sortedStations.length,
                itemBuilder: (context, index) {
                  final station = sortedStations[index];
                  final isFavorite = favoritesNotifier.isFavorite(station.name);
                  final statusColor = metadataNotifier.getStatusColor(station.name);
                  final metadata = metadataNotifier.getMetadata(station.name);
                  final logoUrl = (metadata?.art != null && metadata!.art!.isNotEmpty) ? metadata.art : station.logo;

                  return ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4,
                          height: 48,
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StationLogo(imageUrl: logoUrl, size: 40, borderRadius: 8),
                      ],
                    ),
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
                    onTap: () {
                      final online = metadataNotifier.isOnline(station.name);
                      if (online == true) _openPlayer(station);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
