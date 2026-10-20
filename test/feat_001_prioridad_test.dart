import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'soporte/almacen_en_memoria.dart';

// FEAT-001: clasificación por prioridad (Baja, Media, Alta).
void main() {
  setUp(usarAlmacenEnMemoria);

  test('Una incidencia nueva se crea con prioridad Alta y se conserva al '
      'reiniciar', () async {
    final app = await reabrirApp();
    await app.crear('Servidor caído', 'No responde desde la mañana.',
        'Cliente ficticio', 'Hardware',
        prioridad: 'Alta');
    final id = app.incidencias.first.id;
    expect(app.porId(id)!.prioridad, 'Alta');

    final reabierta = await reabrirApp();
    expect(reabierta.porId(id)!.prioridad, 'Alta');
  });

  test('Si no se elige prioridad al crear, se usa Media', () async {
    final app = await reabrirApp();
    await app.crear('Caso', 'Descripción.', 'Cliente ficticio', 'Software');
    expect(app.incidencias.first.prioridad, 'Media');
  });

  test('Cambiar la prioridad desde el detalle se conserva al reiniciar',
      () async {
    final app = await reabrirApp();
    await app.cambiarPrioridad('INC-101', 'Baja');
    expect(app.porId('INC-101')!.prioridad, 'Baja');

    final reabierta = await reabrirApp();
    expect(reabierta.porId('INC-101')!.prioridad, 'Baja');
  });

  test('Cambiar la prioridad no altera el estado ni los demás registros',
      () async {
    final app = await reabrirApp();
    final antes = {
      for (final x in app.incidencias) x.id: '${x.estado}|${x.prioridad}'
    };

    await app.cambiarPrioridad('INC-103', 'Alta');

    final reabierta = await reabrirApp();
    for (final x in reabierta.incidencias) {
      final esperado =
          x.id == 'INC-103' ? 'Pendiente|Alta' : antes[x.id];
      expect('${x.estado}|${x.prioridad}', esperado, reason: x.id);
    }
  });

  test('Los datos de ejemplo (sin prioridad) abren con prioridad Media',
      () async {
    final app = await reabrirApp();
    expect(app.incidencias, hasLength(10));
    expect(app.incidencias.every((x) => x.prioridad == 'Media'), isTrue);
  });

  test('Registros guardados por la versión anterior abren sin fallar y con '
      'Media', () async {
    // Formato exacto que guardaba la app antes de FEAT-001: sin "prioridad".
    await SharedPreferencesAsync().setString(
      'nexasoft_incidencias_v1',
      jsonEncode([
        {
          'id': 'INC-VIEJO',
          'titulo': 'Registro previo sin prioridad',
          'descripcion': 'Creado con la versión anterior.',
          'cliente': 'Cliente ficticio',
          'categoria': 'Software',
          'estado': 'Resuelta',
          'fecha': '2026-10-19',
        }
      ]),
    );

    final app = await reabrirApp();
    expect(app.porId('INC-VIEJO')!.prioridad, 'Media');
    expect(app.porId('INC-VIEJO')!.estado, 'Resuelta');
  });

  test('Valores fuera de Baja, Media o Alta se tratan como Media al leer', () {
    for (final valor in ['Urgente', 'alta', '', null, 3]) {
      final x = Incidencia.desdeJson({'id': 'X', 'prioridad': valor});
      expect(x.prioridad, 'Media', reason: '$valor');
    }
  });

  test('No se permite guardar una prioridad no aprobada', () async {
    final app = await reabrirApp();
    expect(() => app.cambiarPrioridad('INC-101', 'Urgente'),
        throwsArgumentError);
    expect(
        () => app.crear('T', 'D', 'C', 'Software', prioridad: 'Crítica'),
        throwsArgumentError);
    expect(app.porId('INC-101')!.prioridad, 'Media');
    expect(app.incidencias, hasLength(10));
  });
}
