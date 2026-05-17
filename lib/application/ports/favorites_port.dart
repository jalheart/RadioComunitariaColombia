abstract class FavoritesPort {
  Future<List<String>> getFavorites();
  Future<void> addFavorite(String stationName);
  Future<void> removeFavorite(String stationName);
  Future<bool> isFavorite(String stationName);
  Future<void> toggleFavorite(String stationName);
}
