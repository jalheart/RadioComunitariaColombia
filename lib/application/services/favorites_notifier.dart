import 'package:flutter/material.dart';
import 'favorites_service.dart';

class FavoritesNotifier extends ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();
  List<String> _favorites = [];
  bool _isLoading = true;

  List<String> get favorites => _favorites;
  bool get isLoading => _isLoading;

  FavoritesNotifier() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    _favorites = await _favoritesService.getFavorites();
    _isLoading = false;
    notifyListeners();
  }

  bool isFavorite(String stationName) {
    return _favorites.contains(stationName);
  }

  Future<void> toggleFavorite(String stationName) async {
    await _favoritesService.toggleFavorite(stationName);
    _favorites = await _favoritesService.getFavorites();
    notifyListeners();
  }
}