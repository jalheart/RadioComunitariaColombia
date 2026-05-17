# Tasks: Cargar Metadata de Emisoras vía radioInfoEndpoint

## Contexto

Actualmente el app obtiene la lista de emisoras desde un JSON en Dropbox. Cada emisora tiene un `port` extraído del query param `?p=####` de su URL. Existe la constante `radioInfoEndpoint` (`https://radios.miservidor.cloud/cp/get_info.php?p=`) que nunca se usa.

**Objetivo**: Usar `radioInfoEndpoint + port` para obtener metadata en tiempo real de cada emisora (canción actual, oyentes, bitrate, artwork) y determinar si está online/offline según las reglas de negocio.

**Endpoint**: `https://radios.miservidor.cloud/cp/get_info.php?p={port}`

**Respuesta JSON**:
```json
{
  "history": ["nombreDeLaCancion"],
  "title": "tituloDeLaCancionActual",
  "art": "UrlDeLaImagenQueSeUsaráComoIconoDeLaEmisora",
  "ulisteners": 123,
  "listeners": 123,
  "bitrate": 128000
}
```

**Reglas de negocio para determinar offline**:
1. No hay respuesta del servidor (timeout/error HTTP)
2. `history` no existe O es un arreglo vacío (`[]`)
3. `title` está vacío (`""`)

---

## Tareas

### Fase 0 — Corrección previa necesaria

- [x] **R0**: Corregir `streamUrl` en `RadioStation` para Shoutcast
  - Fix: Cambiar scheme de `https` a `http` y path de `/stream` a `/;stream.mp3` (formato Shoutcast)
  - Archivos: `lib/domain/entities/radio_station.dart`, `test/domain/entities/radio_station_test.dart`
  - Verificado: `http://radios.miservidor.cloud:8286/` responde (Shoutcast server); `https://...` no responde

### Fase 1 — Domain Layer

- [x] **1.1**: Crear entidad `StationMetadata` en `lib/domain/entities/station_metadata.dart`
  - Atributos: `history` (`List<String>`), `title` (`String?`), `art` (`String?`), `ulisteners` (`int`), `listeners` (`int`), `bitrate` (`int`)
  - Método `bool get isOnline` que implemente las reglas de negocio:
    - `history` no es null y no está vacío
    - `title` no es null y no está vacío
  - Factory `StationMetadata.fromJson(Map<String, dynamic> json)` para parsear la respuesta
  - Implementar `==`, `hashCode`, `toString`, `copyWith`

- [x] **1.2**: Agregar método `get infoUrl` a `RadioStation` en `lib/domain/entities/radio_station.dart`
  - Retorna `$radioInfoEndpoint$port` si `port` no es null
  - Retorna `null` si no hay port

### Fase 2 — Infrastructure Layer

- [x] **2.1**: Crear `StationMetadataRemoteDataSource` en `lib/infrastructure/datasources/station_metadata_remote_datasource.dart`
  - Método `Future<StationMetadata?> fetchMetadata(String port)`
  - Usar `http.Client` para GET a `radioInfoEndpoint + port`
  - Timeout de 5 segundos
  - Si hay error de red/timeout → retornar `null` (offline)
  - Si status != 200 → retornar `null` (offline)
  - Si JSON inválido → retornar `null`
  - Si JSON válido → parsear con `StationMetadata.fromJson()` y retornarlo

- [x] **2.2**: Agregar método `getStationMetadata` a `RadioStationRepository` (interfaz) en `lib/domain/repositories/radio_station_repository.dart`
  - `Future<StationMetadata?> getStationMetadata(String port)`

- [x] **2.3**: Implementar `getStationMetadata` en `RadioStationRepositoryImpl`
  - Delegar a `StationMetadataRemoteDataSource.fetchMetadata(port)`

### Fase 3 — Application Layer

- [x] **3.1**: Crear `GetStationMetadataUseCase` en `lib/application/usecases/get_station_metadata_usecase.dart`
  - Método `Future<StationMetadata?> call(String port)`
  - Dependencia: `RadioStationRepository`

- [x] **3.2**: Crear `StationMetadataNotifier` (ChangeNotifier/Provider) en `lib/application/services/station_metadata_notifier.dart`
  - Estado: `StationMetadata?` para la emisora actual, `bool isLoading`, `String? error`
  - Método `Future<void> fetchMetadata(String port)` que llama al use case
  - Exponer `StationMetadata?` para que la UI lo consuma

### Fase 4 — Reemplazar Health Check Actual

- [x] **4.1**: Eliminar `_checkStreams()` y `_checkStream()` de `_RadioStationListPageState` en `main.dart`
  - Detalle: Ya no se necesita el HEAD request simple; la metadata endpoint será la fuente de verdad de online/offline

- [x] **4.2**: Migrar el status indicator en la lista para que use `AllStationsMetadataNotifier`
  - Opción: Crear un `AllStationsMetadataNotifier` que itere sobre todas las emisoras y fetchée metadata para cada una
  - El status badge (green/red/grey) debe reflejar `metadata.isOnline`

### Fase 5 — Mostrar Metadata en PlayerPage

- [x] **5.1**: Consumir `StationMetadataNotifier` en `PlayerPage`
  - Mostrar `title` (canción actual) debajo del nombre de la emisora
  - Mostrar `listeners` / `ulisteners` como contador de oyentes en vivo
  - Mostrar `bitrate` formateado (ej. "128 kbps")
  - Usar `art` como imagen de fondo/logo si existe, con fallback al `logo` de la emisora

- [ ] **5.2**: Reemplazar el badge de conexión (wifi verde/rojo) con lógica basada en `stationMetadata.isOnline`
  - Si `isOnline == false` → mostrar offline indicator
  - Si `isOnline == true` → mostrar online indicator + metadata

### Fase 6 — Tests

- [ ] **6.1**: Test unitario para `StationMetadata`
  - Test: `fromJson` con JSON completo
  - Test: `fromJson` con `history` vacío → `isOnline == false`
  - Test: `fromJson` sin `history` → `isOnline == false`
  - Test: `fromJson` con `title` vacío → `isOnline == false`
  - Test: `fromJson` con datos válidos → `isOnline == true`

- [ ] **6.2**: Test unitario para `StationMetadataRemoteDataSource`
  - Test: respuesta HTTP 200 con JSON válido → retorna `StationMetadata`
  - Test: respuesta HTTP 200 con JSON inválido → retorna `null`
  - Test: respuesta HTTP 404 → retorna `null`
  - Test: timeout → retorna `null`
  - Test: error de red → retorna `null`

- [ ] **6.3**: Test unitario para `RadioStation.infoUrl`
  - Test: con port → retorna URL correcta
  - Test: sin port → retorna `null`

- [ ] **6.4**: Test para `GetStationMetadataUseCase`

### Fase 7 — Integración y Verificación

- [ ] **7.1**: Conectar `StationMetadataNotifier` en el árbol de providers de `main.dart`
  - Registrar en `MultiProvider`

- [ ] **7.2**: Verificar que al abrir una emisora en `PlayerPage` se dispare la carga de metadata
  - La metadata debe cargarse tan pronto como se entra a la página

- [ ] **7.3**: Verificar que la lista de emisoras muestre online/offline basado en metadata
  - Tema: llamar a `AllStationsMetadataNotifier.fetchAllMetadata()` después de cargar las estaciones

- [ ] **7.4**: Ejecutar `flutter analyze` y `flutter test` para asegurar que no hay regresiones
