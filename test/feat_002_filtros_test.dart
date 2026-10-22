import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';

import 'soporte/almacen_en_memoria.dart';

// FEAT-002: filtros combinables por texto, estado y prioridad.
void main() {
  setUp(usarAlmacenEnMemoria);

  List<String> ids(List<Incidencia> lista) => lista.map((x) => x.id).toList();

  // INC-101, 102 y 103 en Alta
  Future<GestorIncidencias> appConPrioridades() async {
    final app = await reabrirApp();
    for (final id in ['INC-101', 'INC-102', 'INC-103']) {
      await app.cambiarPrioridad(id, 'Alta');
    }
    return app;
  }

  test('Sin texto ni filtros (Todos / Todas) aparecen todos los registros',
      () async {
    final app = await appConPrioridades();
    expect(app.filtrar(), hasLength(10));
    expect(app.filtrar(texto: '  ', estado: 'Todos', prioridad: 'Todas'),
        hasLength(10));
  });

  test('Filtro de estado: Pendiente, En proceso y Resuelta', () async {
    final app = await appConPrioridades();
    expect(ids(app.filtrar(estado: 'Pendiente')),
        ['INC-101', 'INC-103', 'INC-105', 'INC-108', 'INC-110']);
    expect(ids(app.filtrar(estado: 'En proceso')), ['INC-102', 'INC-106']);
    expect(ids(app.filtrar(estado: 'Resuelta')),
        ['INC-104', 'INC-107', 'INC-109']);
  });

  test('Filtro de prioridad: Baja, Media y Alta', () async {
    final app = await appConPrioridades();
    expect(ids(app.filtrar(prioridad: 'Alta')),
        ['INC-101', 'INC-102', 'INC-103']);
    expect(app.filtrar(prioridad: 'Media'), hasLength(7));
    expect(app.filtrar(prioridad: 'Baja'), isEmpty);
  });

  test('Estado y prioridad se aplican juntos', () async {
    final app = await appConPrioridades();
    expect(ids(app.filtrar(estado: 'Pendiente', prioridad: 'Alta')),
        ['INC-101', 'INC-103']);
    expect(ids(app.filtrar(estado: 'En proceso', prioridad: 'Alta')),
        ['INC-102']);
  });

  test('Texto, estado y prioridad se aplican juntos', () async {
    final app = await appConPrioridades();
    expect(ids(app.filtrar(texto: 'pantalla')), ['INC-103', 'INC-110']);
    expect(
        ids(app.filtrar(
            texto: 'pantalla', estado: 'Pendiente', prioridad: 'Alta')),
        ['INC-103']);
    expect(
        ids(app.filtrar(
            texto: ' TÚNEL ', estado: 'En proceso', prioridad: 'Media')),
        ['INC-106']);
  });

  test('Una combinación sin coincidencias devuelve una lista vacía', () async {
    final app = await appConPrioridades();
    expect(app.filtrar(estado: 'Resuelta', prioridad: 'Alta'), isEmpty);
    expect(app.filtrar(texto: 'wifi', estado: 'Pendiente'), isEmpty);
  });

  test('Los filtros no cambian los totales del tablero', () async {
    final app = await appConPrioridades();
    app.filtrar(texto: 'pantalla', estado: 'Pendiente', prioridad: 'Alta');
    expect(app.contar('Pendiente'), 5);
    expect(app.contar('En proceso'), 2);
    expect(app.contar('Resuelta'), 3);
  });
}
