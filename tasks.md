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

- [ ] **#14**: Tests para `FavoritesNotifier`, `ThemeNotifier`, `SettingsService`
  - Archivos: `test/application/services/`

- [ ] **#15**: Widget tests para pages y `MiniPlayer`
  - Archivo: `test/presentation/`

- ✅ **#16**: Completar tests existentes
  - `test/domain/entities/radio_station_test.dart`: tests de `streamUrl` e `infoUrl` OK
  - `test/infrastructure/datasources/radio_station_remote_datasource_test.dart`: OK
  - Pendiente: test de JSON malformado en `radio_station_remote_datasource_test.dart`

### Fase 3 — Funcionalidades para el usuario

- [ ] **#17**: Búsqueda y filtro de emisoras (nombre, online/offline)
- [ ] **#18**: Modo oscuro (toggle light/dark además de colores de tema)
- [ ] **#19**: Categorías / géneros para agrupar emisoras
- [ ] **#20**: Control de volumen (slider en player page)
- [ ] **#21**: Sleep timer (apagar tras N minutos)
- [ ] **#22**: Parallelizar health checks (hoy secuenciales, usar `Future.wait()`)

### Fase 4 — Profesionalización

- [ ] **#23**: Audio focus y background playback (notificaciones, reproducción en segundo plano)
- [ ] **#24**: Controles en lock screen
- [ ] **#25**: Deep linking (compartir enlace directo a emisora)
- [ ] **#26**: Notificaciones push (alertar cuando favorita vuelve online)
- [ ] **#27**: Soporte multidioma (español e inglés con i18n)

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
