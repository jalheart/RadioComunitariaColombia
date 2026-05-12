# RadioComunitariaColombia

Aplicación móvil para gestionar y reproducir estaciones de radio comunitarias de Colombia.

## Características

- **Listado de emisoras** — Navega por estaciones de radio comunitarias colombianas con indicador de estado online/offline
- **Reproducción de audio** — Streaming de radio en vivo vía `just_audio` con controles de play, pausa y stop
- **Visualizador animado** — Barras espectrales animadas durante la reproducción
- **Favoritos** — Guarda tus emisoras favoritas (persistido con Hive)
- **Reproducción en segundo plano** — Miniplayer persistente mientras navegas
- **Personalización de tema** — 8 colores de tema seleccionables desde ajustes
- **Cache local** — Las emisoras se cachean por 1 hora para funcionar offline
- **Actualización** — Refresca el listado de emisoras manualmente

## Arquitectura

Hexagonal (Ports & Adapters):

```
lib/
├── domain/               # Lógica de negocio (sin dependencias externas)
│   ├── entities/         # RadioStation (entidad inmutable)
│   └── repositories/     # RadioStationRepository (contrato)
├── application/          # Servicios y estado
│   └── services/         # AudioPlayerService, FavoritesService, ThemeNotifier
├── infrastructure/       # Implementaciones externas
│   ├── datasources/      # Remote (HTTP) y Local (Hive)
│   └── repositories/     # RadioStationRepositoryImpl
└── presentation/         # UI con Flutter y Provider
    ├── pages/            # PlayerPage, SettingsPage
    └── widgets/          # MiniPlayer
```

## Stack técnico

| Categoría | Tecnología |
|---|---|
| Framework | Flutter (Dart SDK ^3.11.5) |
| Estado | Provider + ChangeNotifier |
| Audio | just_audio, audio_session |
| Almacenamiento local | Hive, shared_preferences |
| HTTP | paquete http |
|测试 | flutter_test, mocktail |

## Empezar

```bash
flutter pub get
flutter run
```

## Comandos

```bash
flutter analyze     # Análisis y linting
flutter test        # Pruebas
flutter build apk   # Build Android
flutter build ios   # Build iOS
```
