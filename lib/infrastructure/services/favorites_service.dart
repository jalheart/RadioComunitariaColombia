import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../application/ports/favorites_port.dart';

class FavoritesService implements FavoritesPort {
  static const String _boxName = 'favorites';
  static const String _favoritesKey = 'favorite_stations';

  Box? _cachedBox;

  Future<Box> get _boxFuture async {
    if (_cachedBox != null && _cachedBox!.isOpen) {
      return _cachedBox!;
    }
    debugPrint('Opening Hive box: $_boxName');
    _cachedBox = await Hive.openBox(_boxName);
    debugPrint('Box opened, keys: ${_cachedBox!.keys.toList()}');
    return _cachedBox!;
  }

  String _normalizeName(String name) {
    return name.trim().toLowerCase();
  }

  @override
  Future<List<String>> getFavorites() async {
    try {
      final box = await _boxFuture;
      final result = box.get(_favoritesKey, defaultValue: <String>[]);
      final list = result is List ? result.cast<String>() : <String>[];
      debugPrint('getFavorites: $list');
      return list;
    } catch (e) {
      debugPrint('getFavorites error: $e');
      return [];
    }
  }

  @override
  Future<void> addFavorite(String stationName) async {
    try {
      final box = await _boxFuture;
      final favorites = await getFavorites();
      final normalized = _normalizeName(stationName);
      if (!favorites.any((f) => _normalizeName(f) == normalized)) {
        favorites.add(stationName.trim());
        await box.put(_favoritesKey, favorites);
      }
    } catch (_) {}
  }

  @override
  Future<void> removeFavorite(String stationName) async {
    try {
      final box = await _boxFuture;
      final favorites = await getFavorites();
      final normalized = _normalizeName(stationName);
      favorites.removeWhere((f) => _normalizeName(f) == normalized);
      await box.put(_favoritesKey, favorites);
    } catch (_) {}
  }

  @override
  Future<bool> isFavorite(String stationName) async {
    final favorites = await getFavorites();
    final normalized = _normalizeName(stationName);
    return favorites.any((f) => _normalizeName(f) == normalized);
  }

  @override
  Future<void> toggleFavorite(String stationName) async {
    if (await isFavorite(stationName)) {
      await removeFavorite(stationName);
    } else {
      await addFavorite(stationName);
    }
  }
}
