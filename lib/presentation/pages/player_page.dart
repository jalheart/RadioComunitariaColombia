import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/services/audio_player_service.dart';
import '../../application/services/favorites_notifier.dart';
import '../../application/services/station_metadata_notifier.dart';
import '../../domain/entities/radio_station.dart';

class PlayerPage extends StatefulWidget {
  final RadioStation station;
  final VoidCallback? onMinimize;
  final VoidCallback? onClose;

  const PlayerPage({
    super.key, 
    required this.station,
    this.onMinimize,
    this.onClose,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with SingleTickerProviderStateMixin {
  late final AnimationController _spectrumController;
  final List<double> _spectrumData = List.filled(20, 0.1);
  Timer? _spectrumTimer;

  @override
  void initState() {
    super.initState();
    _spectrumController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _spectrumController.repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioService = context.read<AudioPlayerService>();
      audioService.play(widget.station).then((_) {
        if (mounted) {
          _startSpectrumSimulation();
        }
      });
      if (widget.station.port != null && widget.station.port!.isNotEmpty) {
        context.read<StationMetadataNotifier>().fetchMetadata(widget.station.port!);
      }
    });
  }

  @override
  void dispose() {
    _spectrumTimer?.cancel();
    _spectrumController.dispose();
    super.dispose();
  }

  void _startSpectrumSimulation() {
    _spectrumTimer?.cancel();
    _spectrumTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final audioService = context.read<AudioPlayerService>();
      final time = DateTime.now().millisecondsSinceEpoch / 1000.0;

      setState(() {
        final amplitude = audioService.isPlaying
            ? (audioService.isBuffering ? 0.5 : 1.0)
            : 0.1;

        for (int i = 0; i < _spectrumData.length; i++) {
          final wave = math.sin(time * (2.0 + i * 0.3) + i * 0.5) * 0.3 + 0.5;
          final subWave = math.sin(time * (1.7 + i * 0.7)) * 0.15;
          _spectrumData[i] = ((wave + subWave) * amplitude).clamp(0.05, 1.0);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        title: Text(widget.station.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.minimize),
            onPressed: widget.onMinimize,
            tooltip: 'Minimizar',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
            tooltip: 'Cerrar',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              _buildLogo(),
              const SizedBox(height: 12),
              _buildStationInfo(),
              Expanded(child: _buildSpectrumVisualizer()),
              const SizedBox(height: 20),
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final notifier = context.watch<StationMetadataNotifier>();
    final metadata = notifier.metadata;

    final art = metadata?.art;
    final logo = (art != null && art.isNotEmpty) ? art : widget.station.logo;

    final isOnline = metadata != null && metadata.isOnline;

    return Stack(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: logo == null || logo.isEmpty
                ? Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.radio, size: 100, color: Colors.grey),
                  )
                : Image.network(
                    logo,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.radio, size: 100, color: Colors.grey),
                    ),
                  ),
          ),
        ),
        if (!notifier.isLoading)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStationInfo() {
    final notifier = context.watch<StationMetadataNotifier>();
    final metadata = notifier.metadata;

    return Column(
      children: [
        Text(
          widget.station.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (widget.station.slogan != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.station.slogan!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (metadata != null && metadata.title != null && metadata.title!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            metadata.title!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (metadata != null) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMetadataChip(
                Icons.headphones,
                '${metadata.listeners}',
              ),
              const SizedBox(width: 16),
              _buildMetadataChip(
                Icons.speed,
                '${metadata.bitrate} kbps',
              ),
            ],
          ),
        ],
        if (notifier.isLoading) ...[
          const SizedBox(height: 12),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }

  Widget _buildMetadataChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpectrumVisualizer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(_spectrumData.length, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 12,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 12,
                    height: constraints.maxHeight * _spectrumData[index].clamp(0.1, 1.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildControls() {
    return Consumer<AudioPlayerService>(
      builder: (context, audioService, _) {
        final isPlaying = audioService.isPlaying;
        final isLoading = audioService.isLoading;

        if (isLoading) {
          return const CircularProgressIndicator();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.stop, size: 40),
              onPressed: () {
                final audioService = context.read<AudioPlayerService>();
                audioService.stop();
                widget.onClose?.call();
              },
            ),
            const SizedBox(width: 24),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 50,
                  color: Colors.white,
                ),
                onPressed: () => audioService.togglePlayPause(),
              ),
            ),
            const SizedBox(width: 24),
            Consumer<FavoritesNotifier>(
              builder: (context, favoritesNotifier, _) {
                final isFavorite = favoritesNotifier.isFavorite(widget.station.name);
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 40,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    favoritesNotifier.toggleFavorite(widget.station.name);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
