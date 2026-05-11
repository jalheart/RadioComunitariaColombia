import 'package:hive_flutter/hive_flutter.dart';

class FavoritesService {
  static const String _boxName = 'favorites';
  static const String _favoritesKey = 'favorite_stations';

  Future<List<String>> getFavorites() async {
    try {
      final box = await Hive.openBox(_boxName);
      return box.get(_favoritesKey, defaultValue: <String>[]) as List<String>;
    } catch (_) {
      return [];
    }
  }

  Future<void> addFavorite(String stationName) async {
    try {
      final box = await Hive.openBox(_boxName);
      final favorites = await getFavorites();
      if (!favorites.contains(stationName)) {
        favorites.add(stationName);
        await box.put(_favoritesKey, favorites);
      }
    } catch (_) {}
  }

  Future<void> removeFavorite(String stationName) async {
    try {
      final box = await Hive.openBox(_boxName);
      final favorites = await getFavorites();
      favorites.remove(stationName);
      await box.put(_favoritesKey, favorites);
    } catch (_) {}
  }

  Future<bool> isFavorite(String stationName) async {
    final favorites = await getFavorites();
    return favorites.contains(stationName);
  }

  Future<void> toggleFavorite(String stationName) async {
    if (await isFavorite(stationName)) {
      await removeFavorite(stationName);
    } else {
      await addFavorite(stationName);
    }
  }
}