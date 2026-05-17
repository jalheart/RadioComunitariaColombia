import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../infrastructure/services/logo_cache_manager.dart';

class StationLogo extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double borderRadius;
  final bool showStatus;
  final bool isOnline;
  final bool isLoading;
  final List<BoxShadow>? boxShadow;
  final Color? backgroundColor;

  const StationLogo({
    super.key,
    required this.imageUrl,
    this.size = 40,
    this.borderRadius = 8,
    this.showStatus = false,
    this.isOnline = false,
    this.isLoading = false,
    this.boxShadow,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.grey[300];

    final imageWidget = imageUrl == null || imageUrl!.isEmpty
        ? Container(
            color: bgColor,
            child: Icon(Icons.radio, size: size * 0.6, color: Colors.grey),
          )
        : CachedNetworkImage(
            imageUrl: imageUrl!,
            cacheManager: LogoCacheManager(),
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: bgColor),
            errorWidget: (context, url, error) => Container(
              color: bgColor,
              child: Icon(Icons.radio, size: size * 0.6, color: Colors.grey),
            ),
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
          );

    Widget child = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: imageWidget,
      ),
    );

    if (boxShadow != null) {
      child = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow,
        ),
        child: child,
      );
    }

    if (!showStatus) return child;

    return Stack(
      children: [
        child,
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
}
