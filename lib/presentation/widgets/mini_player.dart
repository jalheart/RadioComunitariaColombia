import 'dart:convert';
import 'package:flutter/material.dart';
import '../../application/services/audio_player_service.dart';

class MiniPlayer extends StatelessWidget {
  final AudioPlayerService audioService;
  final VoidCallback onTap;

  const MiniPlayer({
    super.key,
    required this.audioService,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!audioService.hasStation) {
      return const SizedBox.shrink();
    }

    final station = audioService.currentStation!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              child: _buildLogo(station.logo),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (station.slogan != null)
                    Text(
                      station.slogan!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                audioService.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () => audioService.togglePlayPause(),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => audioService.stop(),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(String? logo) {
    if (logo == null || logo.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.radio, size: 30),
      );
    }

    if (logo.startsWith('data:image')) {
      try {
        final base64Data = logo.split(',').last;
        final imageBytes = base64Decode(base64Data);
        return Image.memory(imageBytes, fit: BoxFit.cover);
      } catch (_) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.radio, size: 30),
        );
      }
    }

    if (_isBase64(logo)) {
      try {
        final imageBytes = base64Decode(logo);
        return Image.memory(imageBytes, fit: BoxFit.cover);
      } catch (_) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.radio, size: 30),
        );
      }
    }

    return Image.network(logo, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(
      color: Colors.grey[300],
      child: const Icon(Icons.radio, size: 30),
    ));
  }

  bool _isBase64(String value) {
    try {
      final RegExp base64Regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
      return value.length % 4 == 0 && base64Regex.hasMatch(value);
    } catch (_) {
      return false;
    }
  }
}