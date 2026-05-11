import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../application/services/audio_player_service.dart';
import '../../domain/entities/radio_station.dart';

final audioService = AudioPlayerService();

class StationLogo extends StatefulWidget {
  final String? logo;
  final double size;

  const StationLogo({
    super.key,
    this.logo,
    this.size = 40,
  });

  @override
  State<StationLogo> createState() => _StationLogoState();
}

class _StationLogoState extends State<StationLogo> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(StationLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.logo != widget.logo) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.logo == null || widget.logo!.isEmpty) {
      _imageBytes = null;
      if (mounted) setState(() {});
      return;
    }

    try {
      if (widget.logo!.startsWith('data:image')) {
        final base64Data = widget.logo!.split(',').last;
        _imageBytes = base64Decode(base64Data);
      } else if (_isBase64(widget.logo!)) {
        _imageBytes = base64Decode(widget.logo!);
      }
    } catch (_) {
      _imageBytes = null;
    }

    if (mounted) setState(() {});
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
    if (_imageBytes == null) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.radio, size: widget.size * 0.6),
      );
    }

    return Image.memory(
      _imageBytes!,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.radio, size: widget.size * 0.6),
      ),
    );
  }
}

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
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _error;
  late final AnimationController _spectrumController;
  final List<double> _spectrumData = List.filled(20, 0.1);

  @override
  void initState() {
    super.initState();
    _spectrumController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _spectrumController.repeat();
    _play();
  }

  Future<void> _play() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await audioService.play(widget.station);
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
      _startSpectrumSimulation();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error al reproducir: $e';
      });
    }
  }

  void _startSpectrumSimulation() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      
      if (mounted) {
        setState(() {
          for (int i = 0; i < _spectrumData.length; i++) {
            _spectrumData[i] = (0.2 + (i % 3) * 0.3 + (i % 5) * 0.2) * (0.5 + (i % 7) * 0.5);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _spectrumController.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildLogo(),
            const SizedBox(height: 32),
            _buildStationInfo(),
            const SizedBox(height: 40),
            _buildSpectrumVisualizer(),
            const SizedBox(height: 40),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 200,
      height: 200,
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
        child: _buildLogoImage(),
      ),
    );
  }

  Widget _buildLogoImage() {
    final logo = widget.station.logo;
    
    if (logo != null && !logo.startsWith('data:image') && !_isBase64(logo)) {
      return Image.network(
        logo,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.radio, size: 100, color: Colors.grey),
        ),
      );
    }

    return StationLogo(
      logo: logo,
      size: 200,
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

  Widget _buildStationInfo() {
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
          const SizedBox(height: 8),
          Text(
            widget.station.slogan!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 8),
        Text(
          widget.station.url,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[400],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSpectrumVisualizer() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_spectrumData.length, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 12,
            height: 100 * _spectrumData[index].clamp(0.1, 1.0),
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
          );
        }),
      ),
    );
  }

  Widget _buildControls() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_error != null) {
      return Column(
        children: [
          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _play,
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.stop, size: 40),
          onPressed: () {
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
              _isPlaying ? Icons.pause : Icons.play_arrow,
              size: 50,
              color: Colors.white,
            ),
            onPressed: () => audioService.togglePlayPause(),
          ),
        ),
        const SizedBox(width: 24),
        IconButton(
          icon: const Icon(Icons.favorite_border, size: 40),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Añadido a favoritos')),
            );
          },
        ),
      ],
    );
  }
}