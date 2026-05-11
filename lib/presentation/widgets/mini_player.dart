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
            SizedBox(
              width: 70,
              height: 70,
              child: station.logo == null || station.logo!.isEmpty
                  ? Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.radio, size: 30),
                    )
                  : Image.network(
                      station.logo!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.radio, size: 30),
                      ),
                    ),
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
}