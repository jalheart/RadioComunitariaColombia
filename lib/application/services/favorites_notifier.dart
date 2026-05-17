import 'package:flutter/material.dart';
import '../../infrastructure/services/favorites_service.dart';

class FavoritesNotifier extends ChangeNotifier {
  final FavoritesService _favoritesService;

  FavoritesNotifier({FavoritesService? favoritesService})
      : _favoritesService = favoritesService ?? FavoritesService() {
    _loadFavorites();
  }

  List<String> _favorites = [];
  bool _isLoading = true;

  List<String> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> _loadFavorites() async {
    try {
      _favorites = await _favoritesService.getFavorites();
    } catch (_) {
      _favorites = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshFavorites() async {
    _favorites = await _favoritesService.getFavorites();
    notifyListeners();
  }

  String _normalizeName(String name) {
    return name.trim().toLowerCase();
  }

  bool isFavorite(String stationName) {
    final normalized = _normalizeName(stationName);
    return _favorites.any((f) => _normalizeName(f) == normalized);
  }

  Future<void> toggleFavorite(String stationName) async {
    await _favoritesService.toggleFavorite(stationName.trim());
    await refreshFavorites();
  }
}