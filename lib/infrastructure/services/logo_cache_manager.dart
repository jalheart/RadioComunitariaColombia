import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class LogoCacheManager extends CacheManager with ImageCacheManager {
  static const String keyName = 'logoCache';
  static final LogoCacheManager _instance = LogoCacheManager._();
  factory LogoCacheManager() => _instance;

  LogoCacheManager._()
      : super(
          Config(
            keyName,
            stalePeriod: const Duration(days: 30),
            maxNrOfCacheObjects: 500,
          ),
        );
}
