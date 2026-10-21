import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Sustituye el almacenamiento del dispositivo por uno en memoria, vacío,
/// para que cada prueba arranque con los datos del JSON de ejemplo.
void usarAlmacenEnMemoria() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
  // rootBundle guarda en caché la lectura del JSON; en pruebas de pantalla esa
  // lectura queda ligada a la prueba anterior y nunca termina.
  rootBundle.clear();
}

/// Simula cerrar y volver a abrir la app: un gestor nuevo que lee
/// únicamente lo que quedó guardado en el almacenamiento.
Future<GestorIncidencias> reabrirApp() async {
  final gestor = GestorIncidencias();
  await gestor.iniciar();
  return gestor;
}
