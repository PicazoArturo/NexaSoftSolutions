import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';

import 'soporte/almacen_en_memoria.dart';

// BUG-003: el tablero presenta cantidades incorrectas.
void main() {
  setUp(usarAlmacenEnMemoria);

  // contar a mano para comparar con el tablero
  int contarAMano(GestorIncidencias app, String estado) =>
      app.incidencias.where((x) => x.estado == estado).length;

  void tableroCoincide(GestorIncidencias app) {
    for (final estado in ['Pendiente', 'En proceso', 'Resuelta']) {
      expect(app.contar(estado), contarAMano(app, estado), reason: estado);
    }
  }

  test('Datos iniciales: 5 pendientes, 2 en proceso, 3 resueltas', () async {
    final app = await reabrirApp();
    expect(app.contar('Pendiente'), 5);
    expect(app.contar('En proceso'), 2);
    expect(app.contar('Resuelta'), 3);
  });

  test('Pendiente → Resuelta y de regreso actualiza el tablero', () async {
    final app = await reabrirApp();

    await app.cambiarEstado('INC-101', 'Resuelta');
    expect(app.contar('Pendiente'), 4);
    expect(app.contar('Resuelta'), 4);
    tableroCoincide(app);

    await app.cambiarEstado('INC-101', 'Pendiente');
    expect(app.contar('Pendiente'), 5);
    expect(app.contar('Resuelta'), 3);
    tableroCoincide(app);
  });

  test('Registrar un caso nuevo y reiniciar mantiene el conteo', () async {
    final app = await reabrirApp();
    await app.crear('Caso nuevo', 'Descripción ficticia.', 'Cliente ficticio',
        'Software');
    expect(app.contar('Pendiente'), 6);
    tableroCoincide(app);

    final reabierta = await reabrirApp();
    expect(reabierta.contar('Pendiente'), 6);
    tableroCoincide(reabierta);
  });

  test('Los totales no dependen de la búsqueda', () async {
    final app = await reabrirApp();
    app.buscar('wifi');
    expect(app.contar('Pendiente'), 5);
    tableroCoincide(app);
  });
}
