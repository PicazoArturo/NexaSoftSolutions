import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

// cada prueba empieza con el almacenamiento vacio
void usarAlmacenEnMemoria() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
  // sin esto la segunda prueba de pantalla se queda cargando
  rootBundle.clear();
}

// como cerrar y volver a abrir la app
Future<GestorIncidencias> reabrirApp() async {
  final gestor = GestorIncidencias();
  await gestor.iniciar();
  return gestor;
}
