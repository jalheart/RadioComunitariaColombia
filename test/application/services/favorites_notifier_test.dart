import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rcc/application/services/favorites_notifier.dart';
import 'package:rcc/infrastructure/services/favorites_service.dart';

class MockFavoritesService extends Mock implements FavoritesService {}

void main() {
  late FavoritesNotifier notifier;
  late MockFavoritesService mockService;

  setUp(() {
    mockService = MockFavoritesService();
  });

  group('initialization', () {
    test('should load favorites on creation', () async {
      when(() => mockService.getFavorites())
          .thenAnswer((_) async => ['Radio Colombia']);

      notifier = FavoritesNotifier(favoritesService: mockService);

      await Future<void>.delayed(Duration.zero);

      expect(notifier.isLoading, false);
      expect(notifier.favorites, ['Radio Colombia']);
    });

    test('should handle error during loading', () async {
      when(() => mockService.getFavorites())
          .thenThrow(Exception('Failed'));

      notifier = FavoritesNotifier(favoritesService: mockService);

      await Future<void>.delayed(Duration.zero);

      expect(notifier.isLoading, false);
      expect(notifier.favorites, isEmpty);
    });
  });

  group('isFavorite', () {
    test('should return true for a favorited station', () async {
      when(() => mockService.getFavorites())
          .thenAnswer((_) async => ['Radio Colombia']);

      notifier = FavoritesNotifier(favoritesService: mockService);
      await Future<void>.delayed(Duration.zero);

      final result = notifier.isFavorite('Radio Colombia');

      expect(result, true);
    });

    test('should return false for a non-favorited station', () async {
      when(() => mockService.getFavorites())
          .thenAnswer((_) async => ['Radio Colombia']);

      notifier = FavoritesNotifier(favoritesService: mockService);
      await Future<void>.delayed(Duration.zero);

      final result = notifier.isFavorite('Radio Bogotá');

      expect(result, false);
    });

    test('should normalize name when checking', () async {
      when(() => mockService.getFavorites())
          .thenAnswer((_) async => ['Radio Colombia']);

      notifier = FavoritesNotifier(favoritesService: mockService);
      await Future<void>.delayed(Duration.zero);

      final result = notifier.isFavorite('  radio colombia  ');

      expect(result, true);
    });
  });

  group('toggleFavorite', () {
    test('should call toggleFavorite on service and refresh', () async {
      when(() => mockService.getFavorites())
          .thenAnswer((_) async => <String>[]);
      when(() => mockService.toggleFavorite('Radio Colombia'))
          .thenAnswer((_) async {});
      when(() => mockService.getFavorites())
          .thenAnswer((_) async => ['Radio Colombia']);

      notifier = FavoritesNotifier(favoritesService: mockService);
      await Future<void>.delayed(Duration.zero);

      await notifier.toggleFavorite('Radio Colombia');

      verify(() => mockService.toggleFavorite('Radio Colombia')).called(1);
      expect(notifier.favorites, ['Radio Colombia']);
    });
  });

  group('refreshFavorites', () {
    test('should reload favorites from service', () async {
      when(() => mockService.getFavorites())
          .thenAnswer((_) async => <String>[]);

      notifier = FavoritesNotifier(favoritesService: mockService);
      await Future<void>.delayed(Duration.zero);

      when(() => mockService.getFavorites())
          .thenAnswer((_) async => ['Radio Colombia']);

      await notifier.refreshFavorites();

      expect(notifier.favorites, ['Radio Colombia']);
    });
  });
}
