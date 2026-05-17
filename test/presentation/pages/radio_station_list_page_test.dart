import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:rcc/application/services/all_stations_metadata_notifier.dart';
import 'package:rcc/application/services/audio_player_service.dart';
import 'package:rcc/application/services/favorites_notifier.dart';
import 'package:rcc/application/services/station_metadata_notifier.dart';
import 'package:rcc/application/services/theme_notifier.dart';
import 'package:rcc/application/usecases/get_station_metadata_usecase.dart';
import 'package:rcc/domain/entities/radio_station.dart';
import 'package:rcc/domain/entities/station_metadata.dart';
import 'package:rcc/infrastructure/repositories/radio_station_repository_impl.dart';
import 'package:rcc/infrastructure/services/favorites_service.dart';
import 'package:rcc/infrastructure/services/settings_service.dart';
import 'package:rcc/presentation/pages/radio_station_list_page.dart';

class MockRadioStationRepositoryImpl extends Mock
    implements RadioStationRepositoryImpl {}

class MockGetStationMetadataUseCase extends Mock
    implements GetStationMetadataUseCase {}

class MockFavoritesService extends Mock implements FavoritesService {}

class MockSettingsService extends Mock implements SettingsService {}

Widget createTestApp({
  required RadioStationRepositoryImpl repository,
  required GetStationMetadataUseCase metadataUseCase,
  required FavoritesService favoritesService,
  required SettingsService settingsService,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => ThemeNotifier(settingsService: settingsService),
      ),
      ChangeNotifierProvider(create: (_) => AudioPlayerService()),
      ChangeNotifierProvider(
        create: (_) => FavoritesNotifier(favoritesService: favoritesService),
      ),
      Provider<GetStationMetadataUseCase>.value(value: metadataUseCase),
      ChangeNotifierProvider(
        create: (context) => AllStationsMetadataNotifier(
          getStationMetadataUseCase: context.read<GetStationMetadataUseCase>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => StationMetadataNotifier(
          getStationMetadataUseCase: context.read<GetStationMetadataUseCase>(),
        ),
      ),
    ],
    child: MaterialApp(
      home: RadioStationListPage(repository: repository),
    ),
  );
}

void main() {
  late MockRadioStationRepositoryImpl mockRepository;
  late MockGetStationMetadataUseCase mockMetadataUseCase;
  late MockFavoritesService mockFavoritesService;
  late MockSettingsService mockSettingsService;

  setUp(() {
    mockRepository = MockRadioStationRepositoryImpl();
    mockMetadataUseCase = MockGetStationMetadataUseCase();
    mockFavoritesService = MockFavoritesService();
    mockSettingsService = MockSettingsService();
    when(() => mockSettingsService.getThemeColor())
        .thenAnswer((_) async => 0xFF6750A4);
    when(() => mockFavoritesService.getFavorites())
        .thenAnswer((_) async => []);
  });

  group('RadioStationListPage - Search & Filter', () {
    testWidgets('should render search TextField and filter Switch',
        (tester) async {
      when(() => mockRepository.getRadioStations())
          .thenAnswer((_) async => [RadioStation(name: 'Test', url: 'http://test.com')]);

      await tester.pumpWidget(createTestApp(
        repository: mockRepository,
        metadataUseCase: mockMetadataUseCase,
        favoritesService: mockFavoritesService,
        settingsService: mockSettingsService,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should filter stations when typing in search field',
        (tester) async {
      final stations = [
        RadioStation(name: 'Radio Uno', url: 'http://uno.com'),
        RadioStation(name: 'Radio Dos', url: 'http://dos.com'),
        RadioStation(name: 'FM Tres', url: 'http://tres.com'),
      ];
      when(() => mockRepository.getRadioStations())
          .thenAnswer((_) async => stations);

      await tester.pumpWidget(createTestApp(
        repository: mockRepository,
        metadataUseCase: mockMetadataUseCase,
        favoritesService: mockFavoritesService,
        settingsService: mockSettingsService,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('Radio Uno'), findsOneWidget);
      expect(find.text('Radio Dos'), findsOneWidget);
      expect(find.text('FM Tres'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Radio');
      await tester.pump();
      await tester.pump();

      expect(find.text('Radio Uno'), findsOneWidget);
      expect(find.text('Radio Dos'), findsOneWidget);
      expect(find.text('FM Tres'), findsNothing);
    });

    testWidgets('should filter only online stations when toggle is on',
        (tester) async {
      final onlineStation = RadioStation(
        name: 'Radio Online',
        url: 'http://online.com',
        port: '8000',
      );
      final offlineStation = RadioStation(
        name: 'Radio Offline',
        url: 'http://offline.com',
        port: '8001',
      );
      final onlineMetadata = StationMetadata(
        history: ['song'],
        title: 'Playing',
        ulisteners: 10,
        listeners: 5,
        bitrate: 128,
      );
      final offlineMetadata = StationMetadata(
        history: [],
        title: null,
        ulisteners: 0,
        listeners: 0,
        bitrate: 0,
      );

      when(() => mockRepository.getRadioStations())
          .thenAnswer((_) async => [onlineStation, offlineStation]);
      when(() => mockMetadataUseCase.call('8000'))
          .thenAnswer((_) async => onlineMetadata);
      when(() => mockMetadataUseCase.call('8001'))
          .thenAnswer((_) async => offlineMetadata);

      await tester.pumpWidget(createTestApp(
        repository: mockRepository,
        metadataUseCase: mockMetadataUseCase,
        favoritesService: mockFavoritesService,
        settingsService: mockSettingsService,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('Radio Online'), findsOneWidget);
      expect(find.text('Radio Offline'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump();

      expect(find.text('Radio Online'), findsOneWidget);
      expect(find.text('Radio Offline'), findsNothing);
    });
  });
}
