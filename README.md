# NexaSoft - Incidencias

Práctica 01 de Dispositivos Móviles: mantenimiento de la app de incidencias de NexaSoft (Flutter). Todos los datos son ficticios.

## Cómo correrla

```
flutter pub get
flutter run -d chrome
```

En Mac también se puede correr con `flutter run -d macos`. Ahí los datos se quedan guardados aunque cierres la app.

Pruebas:

```
flutter test
```

## Qué se hizo

- BUG-001: el estado no se guardaba al cambiarlo. Ahora se guarda.
- BUG-002: la búsqueda distinguía mayúsculas y solo buscaba en el título. Ahora no distingue mayúsculas y busca también en la descripción.
- BUG-003: el contador de pendientes no se actualizaba. Ahora se cuenta desde la lista.
- FEAT-001: prioridad Baja / Media / Alta. Los registros viejos abren con Media.
- FEAT-002: filtros por estado y prioridad junto con la búsqueda, y un botón para limpiarlos.

Cada ticket se trabajó en su propia rama (`fix/bug-001`, `feat/prioridades`, etc.). La versión que se entrega es la etiqueta `v1.0-entrega`.

Las capturas y las salidas de las pruebas están en `docs/evidencias/`.
