import 'package:flutter/material.dart';
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
import 'application/services/station_metadata_notifier.dart';
import 'application/usecases/get_station_metadata_usecase.dart';
import 'presentation/pages/radio_station_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => AudioPlayerService()),
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
            title: 'Radio Comunitaria Colombia',
            theme: themeNotifier.theme,
            home: const RadioStationListPage(),
          );
        },
      ),
    );
  }
}

