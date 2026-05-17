import '../services/favorites_service.dart';

class ToggleFavoriteUseCase {
  final FavoritesService favoritesService;

  ToggleFavoriteUseCase({required this.favoritesService});

  Future<void> call(String stationName) {
    return favoritesService.toggleFavorite(stationName);
  }
}
