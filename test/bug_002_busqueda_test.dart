import 'package:flutter_test/flutter_test.dart';

import 'soporte/almacen_en_memoria.dart';

// BUG-002: la búsqueda omite registros existentes.
void main() {
  setUp(usarAlmacenEnMemoria);

  List<String> ids(List<dynamic> lista) =>
      lista.map((x) => x.id as String).toList();

  test('"wifi" en minúsculas encuentra "WiFi intermitente en recepción"',
      () async {
    final app = await reabrirApp();
    expect(ids(app.buscar('wifi')), ['INC-102']);
  });

  test('"WiFi" con mayúsculas también la encuentra', () async {
    final app = await reabrirApp();
    expect(ids(app.buscar('WiFi')), ['INC-102']);
  });

  test('"túnel" solo aparece en la descripción de la VPN y la encuentra',
      () async {
    final app = await reabrirApp();
    expect(ids(app.buscar('túnel')), ['INC-106']);
  });

  test('Ignora espacios sobrantes al inicio y al final', () async {
    final app = await reabrirApp();
    expect(ids(app.buscar('   wifi   ')), ['INC-102']);
  });

  test('Sin texto muestra todos los registros', () async {
    final app = await reabrirApp();
    expect(app.buscar('').length, app.incidencias.length);
    expect(app.buscar('    ').length, app.incidencias.length);
  });
}
