# Roadmap — RadioComunitariaColombia

Priorización basada en análisis del códigobase (mayo 2026).

---

## Fase 0 — Correcciones críticas

| # | Tarea | Archivos afectados | Razón | Estado |
|---|---|---|---|---|
| 1 | Arreglar `streamUrl` + `_extractPort` | `infrastructure/datasources/radio_station_remote_datasource.dart` | `fetchRadioStations()` prioriza `json['port']` (int → String con `?.toString()`) sobre `_extractPort(url)` | ✅ |
| 2 | Corregir `play()` / `resume()` en AudioPlayerService | `application/services/audio_player_service.dart` | Los callbacks `.then()` setean `_isPlaying = false` después de un play exitoso | ✅ |
| 3 | Agregar `_audioPlayer.dispose()` | `application/services/audio_player_service.dart` | Fuga de memoria — el `AudioPlayer` nunca se libera | ✅ |

---

## Fase 1 — Deuda arquitectónica

| # | Tarea | Archivos afectados | Estado |
|---|---|---|---|
| 4 | Extraer `RadioStationListPage` de `main.dart` a `presentation/pages/` | `main.dart` → `presentation/pages/radio_station_list_page.dart` | ✅ |
| 5 | Crear casos de uso en `application/` (GetRadioStationsUseCase, ToggleFavoriteUseCase, etc.) | `application/usecases/` (nuevo directorio) | ✅ |
| 6 | Definir puertos en `application/ports/` (interfaces para audio, favoritos, settings) | `application/ports/` (hoy vacío) | ✅ |
| 7 | Mover `FavoritesService` y `SettingsService` a `infrastructure/` | Violación hexagonal: usan Hive (externa) pero viven en `application/` | ✅ |
| 8 | Agregar `refreshRadioStations()` y `clearCache()` a la interfaz `RadioStationRepository` | `domain/repositories/radio_station_repository.dart` | ✅ |
| 9 | Extraer widget compartido `StationLogo` | Lógica de logo duplicada en `main.dart`, `player_page.dart` y `mini_player.dart` | ✅ |
| 10 | Limpiar dependencias muertas | `shared_preferences`, `audio_session`, `cupertino_icons` declaradas pero nunca importadas | ✅ |

---

## Fase 2 — Testing

| # | Tarea | Archivo de test | Estado |
|---|---|---|---|
| 11 | Tests para `AudioPlayerService` | `test/application/services/audio_player_service_test.dart` | ✅ |
| 12 | Tests para `RadioStationLocalDataSource` | `test/infrastructure/datasources/radio_station_local_datasource_test.dart` | ✅ |
| 13 | Tests para `RadioStationRepositoryImpl` | `test/infrastructure/repositories/radio_station_repository_impl_test.dart` | ✅ |
| 14 | Tests para FavoritesService, FavoritesNotifier, ThemeNotifier, SettingsService | `test/application/services/`, `test/infrastructure/services/` | ✅ |
| 15 | Widget tests para pages y mini_player | `test/presentation/` | ✅ |
| 16 | Completar tests existentes — `streamUrl` getter, errores de red, JSON malformado | `test/domain/entities/radio_station_test.dart`, `test/infrastructure/datasources/radio_station_remote_datasource_test.dart` | ✅ |

---

## Fase 3 — Funcionalidades para el usuario

| # | Tarea | Descripción | Estado |
|---|---|---|---|
| 17 | Búsqueda y filtro de emisoras | Buscar por nombre, filtrar por online/offline | ✅ |
| 18 | Modo oscuro | Toggle light/dark además de los 8 colores de tema actuales | ✅ |
| 21 | Sleep timer | Apagar reproducción tras N minutos seleccionables | ✅ |
| 22 | Parallelizar health checks | `Future.wait()` con `maxConcurrent` opcional. Test: `test/application/services/all_stations_metadata_notifier_test.dart` | ✅ |

---

## Fase 4 — Profesionalización

| # | Tarea | Descripción | Estado |
|---|---|---|---|
| 23 | Audio focus y background playback | Integrar `audio_session` correctamente para notificaciones y reproducción en segundo plano | [ ] |
| 24 | Controles en lock screen | Play/pause/stop desde pantalla bloqueada | [ ] |
| 25 | Deep linking | Compartir enlace directo a una emisora | [ ] |
| 26 | Notificaciones push | Alertar cuando una emisora favorita vuelve online | [ ] |
| 27 | Soporte multidioma | Al menos español e inglés con internacionalización (i18n) | [ ] |
