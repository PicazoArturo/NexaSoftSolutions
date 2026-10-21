import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/ui/pantalla_principal.dart';

import 'soporte/almacen_en_memoria.dart';

// FEAT-002: la pantalla principal combina filtros, los restablece y avisa
// cuando no hay resultados.
void main() {
  setUp(usarAlmacenEnMemoria);

  Future<void> abrirPantalla(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: PantallaPrincipal()));
    // La carga lee el JSON y el almacenamiento de forma asíncrona real.
    for (var i = 0;
        i < 50 && find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
        i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> elegir(WidgetTester tester, String filtro, String opcion) async {
    await tester.tap(find.byKey(Key(filtro)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(opcion).last);
    await tester.pumpAndSettle();
  }

  testWidgets('Texto + estado + prioridad, luego Limpiar restablece todo',
      (tester) async {
    await abrirPantalla(tester);
    expect(find.text('10 registros'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'pantalla');
    await tester.pumpAndSettle();
    expect(find.text('2 registros'), findsOneWidget);

    await elegir(tester, 'filtro-estado', 'Resuelta');
    expect(find.text('0 registros'), findsOneWidget);
    expect(find.text('Ninguna incidencia coincide con la búsqueda y los '
        'filtros.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('limpiar-filtros')));
    await tester.pumpAndSettle();
    expect(find.text('10 registros'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'pantalla'), findsNothing);
  });

  testWidgets('Filtro de prioridad sin texto', (tester) async {
    await abrirPantalla(tester);
    await elegir(tester, 'filtro-prioridad', 'Baja');
    expect(find.text('0 registros'), findsOneWidget);
    await elegir(tester, 'filtro-prioridad', 'Media');
    expect(find.text('10 registros'), findsOneWidget);
  });
}
