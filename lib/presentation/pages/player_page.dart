import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/services/audio_player_service.dart';
import '../../application/services/favorites_notifier.dart';
import '../../application/services/sleep_timer_service.dart';
import '../../application/services/station_metadata_notifier.dart';
import '../../domain/entities/radio_station.dart';
import '../widgets/station_logo.dart';

class PlayerPage extends StatefulWidget {
  final RadioStation station;
  final String? logoUrl;
  final VoidCallback? onMinimize;
  final VoidCallback? onClose;

  const PlayerPage({
    super.key, 
    required this.station,
    this.logoUrl,
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

      final sleepTimer = context.read<SleepTimerService>();
      sleepTimer.onExpired = () {
        if (!mounted) return;
        audioService.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sleep timer completado — reproducción detenida'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onClose?.call();
      };
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

  void _showSleepTimerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _SleepTimerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        title: Text(widget.station.name),
        actions: [
          Consumer<SleepTimerService>(
            builder: (context, timer, _) {
              final icon = timer.isActive
                  ? Icons.timer_off_outlined
                  : Icons.timer_outlined;
              final tooltip = timer.isActive
                  ? 'Sleep timer: ${timer.formattedTime}'
                  : 'Sleep timer';
              return IconButton(
                icon: timer.isActive
                    ? Badge(
                        label: Text(timer.formattedTime),
                        child: Icon(icon),
                      )
                    : Icon(icon),
                onPressed: () => _showSleepTimerSheet(context),
                tooltip: tooltip,
              );
            },
          ),
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

    final isOnline = metadata != null && metadata.isOnline;

    return StationLogo(
      imageUrl: widget.logoUrl,
      size: 150,
      borderRadius: 20,
      showStatus: !notifier.isLoading,
      isOnline: isOnline,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
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
          _MarqueeText(
            key: ValueKey(metadata.title),
            text: metadata.title!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
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
        Consumer<AudioPlayerService>(
          builder: (context, audioService, _) {
            final error = audioService.error;
            if (error == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                error,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
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
    final notifier = context.watch<StationMetadataNotifier>();
    final metadata = notifier.metadata;
    final isOnline = metadata != null && metadata.isOnline;

    if (!isOnline) return const SizedBox.shrink();

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

class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const _MarqueeText({super.key, required this.text, this.style});

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  void _startScroll() {
    if (!mounted || !_controller.hasClients) return;
    final maxScroll = _controller.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    _controller
        .animateTo(
      maxScroll,
      duration: Duration(milliseconds: (maxScroll * 30).toInt().clamp(1000, 15000)),
      curve: Curves.linear,
    )
        .then((_) {
      if (!mounted) return;
      _controller.jumpTo(0);
      _startScroll();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      child: Text(widget.text, style: widget.style, softWrap: false),
    );
  }
}

class _SleepTimerSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final timer = context.watch<SleepTimerService>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              timer.isActive
                  ? 'Sleep timer activo — ${timer.formattedTime}'
                  : 'Sleep timer',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ..._buildOption(
              context: context,
              minutes: 15,
              timer: timer,
            ),
            ..._buildOption(
              context: context,
              minutes: 30,
              timer: timer,
            ),
            ..._buildOption(
              context: context,
              minutes: 45,
              timer: timer,
            ),
            ..._buildOption(
              context: context,
              minutes: 60,
              timer: timer,
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Personalizado'),
              trailing: timer.durationMinutes > 0 &&
                      ![15, 30, 45, 60].contains(timer.durationMinutes)
                  ? Text('${timer.durationMinutes} min')
                  : null,
              onTap: () => _showCustomDialog(context, timer),
            ),
            if (timer.isActive) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  timer.cancel();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.timer_off, color: Colors.red),
                label: const Text(
                  'Cancelar sleep timer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOption({
    required BuildContext context,
    required int minutes,
    required SleepTimerService timer,
  }) {
    final isActive = timer.isActive && timer.durationMinutes == minutes;
    return [
      ListTile(
        leading: Icon(
          isActive ? Icons.timer : Icons.timer_outlined,
          color: isActive ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text('$minutes minutos'),
        trailing: isActive
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        onTap: () {
          timer.start(minutes);
          Navigator.pop(context);
        },
      ),
    ];
  }

  Future<void> _showCustomDialog(
      BuildContext context, SleepTimerService timer) async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sleep timer personalizado'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minutos',
            hintText: 'Ej: 90',
            suffixText: 'min',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(ctx, value);
              }
            },
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      timer.start(result);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
