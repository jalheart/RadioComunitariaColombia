import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rcc/infrastructure/services/favorites_service.dart';

void main() {
  late FavoritesService service;

  setUpAll(() {
    final tempDir = Directory.systemTemp.createTempSync('hive_favorites_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    service = FavoritesService();
    final box = await Hive.openBox('favorites');
    await box.clear();
  });

  tearDownAll(() async {
    final box = await Hive.openBox('favorites');
    await box.close();
    Hive.deleteBoxFromDisk('favorites');
  });

  group('getFavorites', () {
    test('should return empty list when no favorites saved', () async {
      final result = await service.getFavorites();

      expect(result, isEmpty);
    });

    test('should return saved favorites after add', () async {
      await service.addFavorite('Radio Colombia');

      final result = await service.getFavorites();

      expect(result, ['Radio Colombia']);
    });
  });

  group('addFavorite', () {
    test('should add a station to favorites', () async {
      await service.addFavorite('Radio Colombia');

      final result = await service.getFavorites();

      expect(result, ['Radio Colombia']);
    });

    test('should not add duplicate stations', () async {
      await service.addFavorite('Radio Colombia');
      await service.addFavorite('Radio Colombia');

      final result = await service.getFavorites();

      expect(result.length, 1);
    });

    test('should add multiple stations', () async {
      await service.addFavorite('Radio Colombia');
      await service.addFavorite('Radio Bogotá');

      final result = await service.getFavorites();

      expect(result, ['Radio Colombia', 'Radio Bogotá']);
    });

    test('should normalize names before comparing for duplicates', () async {
      await service.addFavorite('Radio Colombia');
      await service.addFavorite('  radio colombia  ');

      final result = await service.getFavorites();

      expect(result.length, 1);
    });
  });

  group('removeFavorite', () {
    test('should remove an existing favorite', () async {
      await service.addFavorite('Radio Colombia');
      await service.addFavorite('Radio Bogotá');
      await service.removeFavorite('Radio Colombia');

      final result = await service.getFavorites();

      expect(result, ['Radio Bogotá']);
    });

    test('should normalize name when removing', () async {
      await service.addFavorite('Radio Colombia');
      await service.removeFavorite('  RADIO COLOMBIA  ');

      final result = await service.getFavorites();

      expect(result, isEmpty);
    });
  });

  group('isFavorite', () {
    test('should return true for an existing favorite', () async {
      await service.addFavorite('Radio Colombia');

      final result = await service.isFavorite('Radio Colombia');

      expect(result, true);
    });

    test('should return false for a non-favorite', () async {
      final result = await service.isFavorite('Unknown Station');

      expect(result, false);
    });

    test('should normalize name when checking', () async {
      await service.addFavorite('Radio Colombia');

      final result = await service.isFavorite('  radio colombia  ');

      expect(result, true);
    });
  });

  group('toggleFavorite', () {
    test('should add a station that is not a favorite', () async {
      await service.toggleFavorite('Radio Colombia');

      final result = await service.isFavorite('Radio Colombia');

      expect(result, true);
    });

    test('should remove a station that is already a favorite', () async {
      await service.addFavorite('Radio Colombia');
      await service.toggleFavorite('Radio Colombia');

      final result = await service.isFavorite('Radio Colombia');

      expect(result, false);
    });
  });
}
