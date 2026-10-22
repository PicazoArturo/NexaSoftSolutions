import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  static const todosLosEstados = 'Todos';
  static const todasLasPrioridades = 'Todas';

  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];

  Future<void> iniciar() async {
    incidencias = await datos.leer();
  }

  List<Incidencia> buscar(String texto) => filtrar(texto: texto);

  // texto, estado y prioridad juntos
  List<Incidencia> filtrar({
    String texto = '',
    String estado = todosLosEstados,
    String prioridad = todasLasPrioridades,
  }) {
    final consulta = texto.trim().toLowerCase();
    return incidencias.where((x) {
      final coincideTexto = consulta.isEmpty ||
          x.titulo.toLowerCase().contains(consulta) ||
          x.descripcion.toLowerCase().contains(consulta);
      final coincideEstado = estado == todosLosEstados || x.estado == estado;
      final coincidePrioridad =
          prioridad == todasLasPrioridades || x.prioridad == prioridad;
      return coincideTexto && coincideEstado && coincidePrioridad;
    }).toList();
  }

  Incidencia? porId(String id) {
    for (var x in incidencias) {
      if (x.id == id) return x;
    }
    return null;
  }

  int contar(String estado) {
    return incidencias.where((x) => x.estado == estado).length;
  }

  Future<void> cambiarEstado(String id, String estado) async {
    final item = porId(id);
    if (item == null) return;
    item.estado = estado;
    await datos.guardar(incidencias);
  }

  Future<void> cambiarPrioridad(String id, String prioridad) async {
    _validarPrioridad(prioridad);
    final item = porId(id);
    if (item == null) return;
    item.prioridad = prioridad;
    await datos.guardar(incidencias);
  }

  Future<void> crear(
      String titulo, String descripcion, String cliente, String categoria,
      {String prioridad = Incidencia.prioridadPorDefecto}) async {
    _validarPrioridad(prioridad);
    final nuevo = Incidencia(
      id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descripcion: descripcion,
      cliente: cliente,
      categoria: categoria,
      estado: 'Pendiente',
      fecha: DateTime.now().toIso8601String().split('T').first,
      prioridad: prioridad,
    );
    incidencias.insert(0, nuevo);
    await datos.guardar(incidencias);
  }

  void _validarPrioridad(String prioridad) {
    if (!Incidencia.prioridades.contains(prioridad)) {
      throw ArgumentError.value(
          prioridad, 'prioridad', 'Debe ser Baja, Media o Alta');
    }
  }

  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}
