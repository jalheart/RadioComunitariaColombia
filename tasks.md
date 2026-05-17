# Tasks: Roadmap — RadioComunitariaColombia

## Completado (Feature Metadata)

Todas las tareas del feature "Cargar Metadata de Emisoras vía radioInfoEndpoint" (Fases 0-7 anteriores) están completadas. Ver histórico abajo.

---

## Roadmap — Pendiente

Priorización basada en análisis del codebase (mayo 2026).

### Fase 0 — Correcciones críticas

- ✅ **#1**: Arreglar `streamUrl` para que genere URL Shoutcast válida
  - Detalle: `fetchRadioStations()` prioriza `json['port']` (int → String con `?.toString()`) sobre `_extractPort(url)`
  - Archivo: `lib/infrastructure/datasources/radio_station_remote_datasource.dart:24`
  - Tests: `test/infrastructure/datasources/radio_station_remote_datasource_test.dart:116-140` (2 tests agregados)

- ✅ **#2**: Corregir `play()` / `resume()` en `AudioPlayerService`
  - Detalle: Los `.then()` callbacks setean `_isPlaying = false` después de un play exitoso
  - Archivo: `lib/application/services/audio_player_service.dart`

- ✅ **#3**: Agregar `_audioPlayer.dispose()`
  - Detalle: Ya existe `dispose()` con `_audioPlayer.dispose()` en `audio_player_service.dart:134-139`

### Fase 1 — Deuda arquitectónica

- ✅ **#4**: Extraer `RadioStationListPage` de `main.dart` a `presentation/pages/radio_station_list_page.dart`
  - Archivos: `lib/main.dart` → `lib/presentation/pages/radio_station_list_page.dart`

- ✅ **#5**: Crear casos de uso faltantes en `application/usecases/`
  - Pendientes: `GetRadioStationsUseCase`, `ToggleFavoriteUseCase`
  - Existe: `GetStationMetadataUseCase`

- ✅ **#6**: Definir puertos en `application/ports/`
  - Interfaces para: audio, favoritos, settings
  - Directorio `lib/application/ports/` no existe actualmente

- ✅ **#7**: Mover `FavoritesService` y `SettingsService` a `infrastructure/`
  - Violación hexagonal: usan Hive (infraestructura externa) pero viven en `application/services/`
  - Archivos: `lib/application/services/favorites_service.dart`, `lib/application/services/settings_service.dart`

- ✅ **#8**: Agregar `refreshRadioStations()` y `clearCache()` a la interfaz `RadioStationRepository`
  - Ya existen en la impl (`radio_station_repository_impl.dart`) pero no están declarados en el contrato abstracto (`domain/repositories/radio_station_repository.dart`)

- ✅ **#9**: Extraer widget compartido `StationLogo`
  - Lógica de logo duplicada en: `main.dart`, `player_page.dart`, `mini_player.dart`

- ✅ **#10**: Limpiar dependencias muertas en `pubspec.yaml`
  - Candidatos: `cupertino_icons`, `audio_session`, `shared_preferences` (declaradas pero nunca importadas)

### Fase 2 — Testing

- ✅ **#11**: Tests para `AudioPlayerService`
  - Archivo: `test/application/services/audio_player_service_test.dart`
  - Detalle: 24 tests que cubren estado inicial, play (nueva estación, misma estación, minimizado, pausado, cambio, error), pause, resume, togglePlayPause, stop, minimize, restore, dispose y stream de estado

- ✅ **#12**: Tests para `RadioStationLocalDataSource`
  - Archivo: `test/infrastructure/datasources/radio_station_local_datasource_test.dart`
  - Detalle: 14 tests con Hive real (temp dir) que cubren CRUD, caché y limpieza

- ✅ **#13**: Tests para `RadioStationRepositoryImpl`
  - Archivo: `test/infrastructure/repositories/radio_station_repository_impl_test.dart`
  - Detalle: 9 tests con mocktail que cubren getRadioStations (caché válida, vacía, inválida), refreshRadioStations, getStationMetadata y clearCache

- ✅ **#14**: Tests para `FavoritesNotifier`, `ThemeNotifier`, `SettingsService`, `FavoritesService`
  - Archivos: `test/application/services/favorites_notifier_test.dart` (7 tests), `test/application/services/theme_notifier_test.dart` (4 tests), `test/infrastructure/services/settings_service_test.dart` (4 tests), `test/infrastructure/services/favorites_service_test.dart` (14 tests)

- ✅ **#15**: Widget tests para pages y widgets
  - Archivos: `test/presentation/pages/settings_page_test.dart` (6 tests), `test/presentation/widgets/mini_player_test.dart` (8 tests), `test/presentation/widgets/station_logo_test.dart` (8 tests)

- ✅ **#16**: Completar tests existentes
  - `test/domain/entities/radio_station_test.dart`: tests de `streamUrl` e `infoUrl` OK
  - `test/infrastructure/datasources/radio_station_remote_datasource_test.dart`: OK
  - Pendiente: test de JSON malformado en `radio_station_remote_datasource_test.dart`

### Fase 3 — Funcionalidades para el usuario

- [ ] **#17**: Búsqueda y filtro de emisoras
  - ✅ **17.1**: Agregar `SearchController` / `SearchBar` widget en `RadioStationListPage` (filtro por nombre o slogan)
  - ✅ **17.2**: Agregar `FilterChip` o toggle para filtrar solo emisoras online/offline
  - ✅ **17.3**: Implementar lógica de búsqueda en `RadioStationListPage` (estado local o notifier) que filtre la lista en tiempo real
  - ✅ **17.4**: Actualizar tests de `radio_station_list_page_test.dart` para cubrir búsqueda y filtro
    - Detalle: Tests usando mock repository que cubren: renderizado de search + toggle, filtro por texto (nombre), y filtro solo online

- [ ] **#18**: Modo oscuro (toggle light/dark además de colores de tema)
  - ✅ **18.1**: Agregar `brightness` (light/dark) al `SettingsPort` y `SettingsService` (persistir en Hive)
  - ✅ **18.2**: Ampliar `ThemeNotifier` para exponer y cambiar `brightness` (`Brightness.light` / `Brightness.dark`)
  - ✅ **18.3**: Agregar `SwitchListTile` de modo oscuro en `SettingsPage`
  - ✅ **18.4**: Actualizar tests de `ThemeNotifier` y `SettingsService`

- ✅ **#21**: Sleep timer (apagar tras N minutos)
  - ✅ **21.1**: Crear `SleepTimerService` en `application/services/` con timer countdown y estado
    - Archivo: `lib/application/services/sleep_timer_service.dart`
    - Extiende `ChangeNotifier`, expone `isActive`, `remainingSeconds`, `durationMinutes`, `formattedTime`
    - Métodos: `start(minutes)`, `cancel()`, callback `onExpired` para detener reproducción
  - ✅ **21.2**: Exponer estado del timer (tiempo restante, activo/inactivo) vía `ChangeNotifier` (+ provider)
    - Archivo: `lib/main.dart` — registro como `ChangeNotifierProvider(create: (_) => SleepTimerService())`
  - ✅ **21.3**: Agregar UI en `PlayerPage` o bottom sheet para seleccionar minutos (15, 30, 45, 60, custom)
    - Archivo: `lib/presentation/pages/player_page.dart`
    - Botón timer en AppBar con badge de tiempo restante cuando activo
    - Bottom sheet `_SleepTimerSheet` con opciones predefinidas (15, 30, 45, 60 min) + personalizado vía `AlertDialog`
    - Botón "Cancelar sleep timer" cuando está activo
  - ✅ **21.4**: Al expirar: detener reproducción (llamar `stop()` en `AudioPlayerService`) y mostrar notificación/snackbar
    - Archivo: `lib/presentation/pages/player_page.dart` — callback `onExpired` en `initState`
    - Llama `audioService.stop()` + `widget.onClose()` + SnackBar flotante "Sleep timer completado"
  - ✅ **21.5**: Agregar tests unitarios para `SleepTimerService`
    - Archivo: `test/application/services/sleep_timer_service_test.dart`
    - 9 tests: estado inicial, start, cancel, formattedTime, countdown, onExpired callback

- ✅ **#22**: Parallelizar health checks (hoy secuenciales, usar `Future.wait()`)
  - ✅ **22.1**: Refactorizar `fetchAllMetadata()` en `AllStationsMetadataNotifier` para lanzar todas las llamadas en paralelo con `Future.wait()`
    - Archivo: `lib/application/services/all_stations_metadata_notifier.dart:34-58`
  - ✅ **22.2**: Manejar fallos parciales (cada `Future` atrapa su error, el `Future.wait` no falla por una)
    - Cada llamada individual atrapa su error en `_fetchMetadataForStation()`, `Future.wait` nunca falla
  - ✅ **22.3**: Agregar límite de concurrencia opcional (ej. batches de 10) para no saturar red
    - Parámetro `maxConcurrent` opcional en `fetchAllMetadata()`
    - Si es null o ≤ 0, lanza todas en paralelo (comportamiento default)
    - Si es > 0, procesa en batches de ese tamaño
  - ✅ **22.4**: Agregar tests del notifier
    - Archivo: `test/application/services/all_stations_metadata_notifier_test.dart` (9 tests)

### Fase 4 — Profesionalización

- ✅ **#23**: Audio focus y background playback (notificaciones, reproducción en segundo plano)
  - ✅ **23.1**: Agregar dependencia `audio_service: ^0.18.18` (elegida sobre `just_audio_background`)
    - Detalle: `pubspec.yaml` — línea agregada debajo de `just_audio`
  - ✅ **23.2**: Configurar `AndroidManifest.xml` para audio_service
    - Detalle: permisos (WAKE_LOCK, FOREGROUND_SERVICE, FOREGROUND_SERVICE_MEDIA_PLAYBACK), activity → AudioServiceActivity, service + receiver agregados
  - ✅ **23.3**: Configurar `UIBackgroundModes` (audio) en iOS `Info.plist`
  - ✅ **23.4**: Integrar `AudioPlayerService` con notificación persistente (título, portada, botones play/pause/stop)
    - Detalle: Creado `RCCAudioHandler` (BaseAudioHandler) en `lib/application/services/rcc_audio_handler.dart`
    - `AudioService.init()` en `main.dart` con configuración de canal de notificación
    - `AudioPlayerService` delega al handler cuando disponible, fallback a AudioPlayer directo en tests
    - Handler expone `play()`, `pause()`, `stop()`, `onTaskRemoved()`, y `setStation()` que actualiza `MediaItem` con nombre, artista y artUri
    - Misma instancia de `AudioPlayer` compartida entre handler y service
  - ✅ **23.5**: Manejar eventos de audio focus (pausar al recibir llamada, reanudar al colgar)
    - Detalle: `audio_session` agregado a pubspec.yaml, configurado en `RCCAudioHandler.initAudioSession()` con `AndroidAudioUsage.media`
    - `interruptionEventStream`: pausa en `begin + pause/unknown`, reanuda en `end + pause`
    - `becomingNoisyEventStream`: pausa al desconectar audífonos
    - Llamado desde `main.dart` después de `AudioService.init()`
  - ✅ **23.6**: Tests de integración para background playback
    - Detalle: 13 tests en `test/application/services/rcc_audio_handler_test.dart`
    - Cubren: play/pause/stop delegation, setStation (URL, metadata, null logo, null slogan), onTaskRemoved, playerStateStream forwarding, seek, shutdown, mediaItem cleanup

- [ ] **#24**: Controles en lock screen
  - **24.1**: Configurar `AudioSession` de `just_audio` para que exponga metadatos al sistema operativo (`MediaItem`)
  - **24.2**: Sincronizar `MediaItem.artist`, `MediaItem.title` y `MediaItem.artUri` con la estación actual
  - **24.3**: Probar en Android (lock screen controls) y iOS (Control Center)

- [ ] **#25**: Deep linking (compartir enlace directo a emisora)
  - **25.1**: Solicitar permiso para dependencia `app_links: ^6.0.0` o `go_router: ^14.0.0`​
  - **25.2**: Definir esquema de URL: `rcc://station/{stationName}` o similar
  - **25.3**: Configurar `intent-filter` en Android `AndroidManifest.xml` (deep link)
  - **25.4**: Manejar enlace entrante en `main.dart` (detectar estación por nombre, navegar a `PlayerPage` y reproducir)
  - **25.5**: Agregar botón "Compartir" en `PlayerPage` que genere el deep link

- [ ] **#26**: Notificaciones push (alertar cuando favorita vuelve online)
  - **26.1**: Solicitar permiso para dependencias `firebase_messaging: ^15.0.0` y `flutter_local_notifications: ^18.0.0`​
  - **26.2**: Configurar Firebase Cloud Messaging (google-services.json, Firebase Console)
  - **26.3**: Implementar `PushNotificationService` que maneje token, recepción y tap de notificaciones
  - **26.4**: Lógica en backend (o polling local) para detectar cuando una favorita offline vuelve online y disparar notificación
  - **26.5**: Manejar tap en notificación → abrir `PlayerPage` con esa estación

- [ ] **#27**: Soporte multidioma (español e inglés con i18n)
  - **27.1**: Agregar dependencias `flutter_localizations` (sdk) e `intl: ^0.19.0`
  - **27.2**: Crear archivos `.arb` para español (`es.arb`) e inglés (`en.arb`) con todas las cadenas de la app
  - **27.3**: Configurar `localizationsDelegates`, `supportedLocales` y `locale` en `MaterialApp`
  - **27.4**: Extraer todos los strings hardcodeados (español) a referencias `AppLocalizations.of(context)!`
  - **27.5**: Agregar selector de idioma en `SettingsPage`
  - **27.6**: Persistir preferencia de idioma en `SettingsService`

---

## Histórico — Feature Metadata (Completado)

### Fase 0 — Corrección previa
- ✅ **R0**: Corregir `streamUrl` en `RadioStation` para Shoutcast (http + /;stream.mp3)

### Fase 1 — Domain Layer
- ✅ **1.1**: Crear entidad `StationMetadata`
- ✅ **1.2**: Agregar `infoUrl` a `RadioStation`

### Fase 2 — Infrastructure Layer
- ✅ **2.1**: Crear `StationMetadataRemoteDataSource`
- ✅ **2.2**: Agregar `getStationMetadata` a la interfaz repository
- ✅ **2.3**: Implementar `getStationMetadata` en `RadioStationRepositoryImpl`

### Fase 3 — Application Layer
- ✅ **3.1**: Crear `GetStationMetadataUseCase`
- ✅ **3.2**: Crear `StationMetadataNotifier`

### Fase 4 — Reemplazar Health Check
- ✅ **4.1**: Eliminar `_checkStreams()` y `_checkStream()`
- ✅ **4.2**: Migrar status indicator a `AllStationsMetadataNotifier`

### Fase 5 — Mostrar Metadata en PlayerPage
- ✅ **5.1**: Consumir `StationMetadataNotifier` en `PlayerPage`
- ✅ **5.2**: Badge online/offline redondo sin icono

### Fase 6 — Tests
- ✅ **6.1-6.4**: Tests para `StationMetadata`, datasource, `infoUrl`, use case

### Fase 7 — Integración
- ✅ **7.1-7.4**: Providers, carga en PlayerPage, lista online/offline, análisis + tests
