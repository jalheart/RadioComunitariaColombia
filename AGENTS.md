# RadioComunitariaColombia - Guía de Desarrollo

## Visión General del Proyecto

Flutter app para gestionar y reproducir estaciones de radio comunitarias de Colombia.

---

## Gestión de Tareas con tasks.md

- Cuando se solicite realizar una acción que implique un listado de tareas (features, refactors, correcciones, etc.), DEBES crear o actualizar el archivo `tasks.md` en la raíz del proyecto
- `tasks.md` debe contener un desglose detallado al mínimo de cada tarea necesaria, con el formato:
  ```markdown
  # Tasks: {Nombre del Proyecto o Feature}

  ## Tareas

  - ✅ **{ID}**: {Descripción clara y accionable de la tarea}
    - Detalle: {pasos específicos si aplica}
  ```
- Cada tarea debe ser atómica y accionable (una persona o agente debe poder completarla)
- Marcar el progreso usando `✅` para tareas completadas y `[ ]` para pendientes
- El archivo `tasks.md` sirve como guía única de referencia; debe mantenerse actualizado durante toda la sesión
- Al finalizar la sesión o el feature, dejar `tasks.md` en el último estado para trazabilidad

## Reglas para Agregar Dependencias

- Antes de agregar cualquier librería externa al `pubspec.yaml`, DEBES pedir permiso explícito
- Explicar para qué se necesita y mencionar alternativas viables si existen
- No agregar librerías sin autorización, incluso si son bien conocidas

## Arquitectura: Hexagonal (Ports & Adapters)

```
lib/
├── domain/                 # Core business logic (sin dependencias externas)
│   ├── entities/          # Entidades del dominio
│   │   └── radio_station.dart
│   └── repositories/       # Interfaces de repositorios (contratos)
│
├── application/           # Casos de uso
│   └── ports/             # Interfaces para adapters (input/output)
│
├── infrastructure/        # Implementaciones externas
│   ├── datasources/       # Fuentes de datos (API, local storage)
│   └── repositories/      # Implementaciones de repositorios
│
└── presentation/          # UI (Flutter widgets, BLoC/Cubit)
    ├── pages/
    ├── widgets/
    └── controllers/
```

### Reglas de Dependencias
- `domain` NO puede depender de ninguna capa externa
- `application` depende solo de `domain`
- `infrastructure` implementa contratos de `domain` y `application`
- `presentation` depende de `application`

---

## Convenciones de Código

### Entidades (domain/entities)
- Usar clases simples de Dart (sin librerías externas)
- Todos los campos final con `const` en constructor
- Incluir `copyWith` para inmutabilidad
- Implementar `==`, `hashCode` y `toString`
- Atributos opcionales como tipos nullable (`String?`)

```dart
class RadioStation {
  final String name;           // requerido
  final String url;            // requerido
  final String? port;          // opcional
  final String? logo;          // opcional
  final String? slogan;        // opcional
}
```

### Repositorios (domain/repositories)
- Interfaz abstracta con métodos async
- Naming: `{Nombre}Repository`
- Ejemplo: `RadioStationRepository`

### Casos de Uso (application)
- Una clase por cada operación de negocio
- Naming: `{Accion}{Entidad}UseCase`
- Ejemplo: `GetRadioStationsUseCase`, `SaveRadioStationUseCase`

### Naming
- Archivos: snake_case (`radio_station.dart`)
- Clases: PascalCase (`class RadioStation`)
- Métodos/variables: camelCase
- Constantes: SCREAMING_SNAKE_CASE

---

## Tests

### Estructura
```
test/
├── domain/
│   └── entities/
│       └── radio_station_test.dart
├── application/
│   └── ports/
└── ...
```

### Convenciones
- Nombre: `{nombre}_test.dart`
- Usar `flutter_test` (incluido en dev_dependencies)
- Un `group` por caso de uso
- `test()` para casos individuales
- `setUp()` para configuración reutilizable

### Ejemplo
```dart
import 'package:flutter_test/flutter_test';
import 'package:rc/domain/entities/radio_station.dart';

void main() {
  group('RadioStation', () {
    test('should create RadioStation with required fields', () {
      final station = RadioStation(
        name: 'Radio Colombia',
        url: 'https://radio.com',
      );

      expect(station.name, 'Radio Colombia');
      expect(station.url, 'https://radio.com');
      expect(station.port, isNull);
    });

    test('should support optional fields', () {
      final station = RadioStation(
        name: 'Radio Colombia',
        url: 'https://radio.com',
        port: '8080',
        logo: 'https://logo.com/logo.png',
        slogan: 'La voz de la comunidad',
      );

      expect(station.port, '8080');
      expect(station.logo, 'https://logo.com/logo.png');
      expect(station.slogan, 'La voz de la comunidad');
    });

    test('copyWith should create new instance with updated values', () {
      final original = RadioStation(
        name: 'Original',
        url: 'https://original.com',
      );

      final copy = original.copyWith(name: 'Updated');

      expect(copy.name, 'Updated');
      expect(copy.url, 'https://original.com');
    });
  });
}
```

---

## Commands

### Análisis y Linting
```bash
flutter analyze
```

### Tests
```bash
flutter test
```

### Build
```bash
flutter build apk      # Android
flutter build ios     # iOS
flutter build web     # Web
```

---

## Próximos Pasos

1. Crear interfaces de repositorios en `domain/repositories`
2. Implementar puertos en `application/ports`
3. Crear datasources en `infrastructure/datasources`
4. Implementar repositorios en `infrastructure/repositories`
5. Agregar casos de uso en `application/usecases`
6. Configurar estado con BLoC/Cubit en `presentation/controllers`