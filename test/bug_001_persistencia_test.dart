import 'package:flutter_test/flutter_test.dart';

import 'soporte/almacen_en_memoria.dart';

// BUG-001: el cambio de estado desaparece al reiniciar la app.
void main() {
  setUp(usarAlmacenEnMemoria);

  test('El nuevo estado se conserva tras cerrar y reabrir la app', () async {
    final app = await reabrirApp();
    expect(app.porId('INC-101')!.estado, 'Pendiente');

    await app.cambiarEstado('INC-101', 'Resuelta');
    expect(app.porId('INC-101')!.estado, 'Resuelta');

    final reabierta = await reabrirApp();
    expect(reabierta.porId('INC-101')!.estado, 'Resuelta');
  });

  test('Una incidencia nueva sigue existiendo tras reiniciar', () async {
    final app = await reabrirApp();
    await app.crear('Monitor sin señal', 'No enciende tras un corte de luz.',
        'Cliente ficticio', 'Hardware');
    final id = app.incidencias.first.id;

    final reabierta = await reabrirApp();
    expect(reabierta.porId(id)?.titulo, 'Monitor sin señal');
  });

  test('Cambiar el estado de un registro no altera los demás', () async {
    final app = await reabrirApp();
    final antes = {for (final x in app.incidencias) x.id: x.estado};

    await app.cambiarEstado('INC-103', 'En proceso');

    final reabierta = await reabrirApp();
    for (final x in reabierta.incidencias) {
      final esperado = x.id == 'INC-103' ? 'En proceso' : antes[x.id];
      expect(x.estado, esperado, reason: x.id);
    }
  });
}
