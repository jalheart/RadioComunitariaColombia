import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'infrastructure/datasources/radio_station_remote_datasource.dart';
import 'infrastructure/datasources/radio_station_local_datasource.dart';
import 'infrastructure/datasources/station_metadata_remote_datasource.dart';
import 'infrastructure/repositories/radio_station_repository_impl.dart';
import 'application/services/audio_player_service.dart';
import 'application/services/theme_notifier.dart';
import 'application/services/favorites_notifier.dart';
import 'application/services/all_stations_metadata_notifier.dart';
import 'application/services/sleep_timer_service.dart';
import 'application/services/station_metadata_notifier.dart';
import 'application/services/rcc_audio_handler.dart';
import 'application/usecases/get_station_metadata_usecase.dart';
import 'presentation/pages/radio_station_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final player = AudioPlayer();

  final audioHandler = await AudioService.init(
    builder: () => RCCAudioHandler(audioPlayer: player),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.jalheart.rcc.channel.audio',
      androidNotificationChannelName: 'Radio Comunitaria de Colombia',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  await audioHandler.initAudioSession();

  runApp(MyApp(audioHandler: audioHandler));
}

class MyApp extends StatelessWidget {
  final RCCAudioHandler? audioHandler;

  const MyApp({super.key, this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        if (audioHandler != null)
          Provider<RCCAudioHandler>.value(value: audioHandler!),
        ChangeNotifierProvider(
          create: (_) => AudioPlayerService(
            audioPlayer: audioHandler?.player,
            handler: audioHandler,
          ),
        ),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => SleepTimerService()),
        ChangeNotifierProvider(create: (_) => FavoritesNotifier()),
        Provider(create: (_) {
          final repository = RadioStationRepositoryImpl(
            remoteDataSource: RadioStationRemoteDataSource(),
            localDataSource: RadioStationLocalDataSource(),
            metadataDataSource: StationMetadataRemoteDataSource(),
          );
          return GetStationMetadataUseCase(repository: repository);
        }),
        ChangeNotifierProvider(create: (context) {
          return AllStationsMetadataNotifier(
            getStationMetadataUseCase: context.read<GetStationMetadataUseCase>(),
          );
        }),
        ChangeNotifierProvider(create: (context) {
          return StationMetadataNotifier(
            getStationMetadataUseCase: context.read<GetStationMetadataUseCase>(),
          );
        }),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, _) {
          if (themeNotifier.isLoading) {
            return MaterialApp(
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          return MaterialApp(
            title: 'Radio Comunitaria de Colombia',
            theme: themeNotifier.theme,
            home: const RadioStationListPage(),
          );
        },
      ),
    );
  }
}
