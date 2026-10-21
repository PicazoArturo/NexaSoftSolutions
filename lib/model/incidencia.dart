class Incidencia {
  static const estados = ['Pendiente', 'En proceso', 'Resuelta'];
  static const prioridades = ['Baja', 'Media', 'Alta'];
  static const prioridadPorDefecto = 'Media';

  String id;
  String titulo;
  String descripcion;
  String cliente;
  String categoria;
  String estado;
  String fecha;
  String prioridad;

  Incidencia({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.cliente,
    required this.categoria,
    required this.estado,
    required this.fecha,
    this.prioridad = prioridadPorDefecto,
  });

  /// Registros anteriores a FEAT-001 no traen prioridad; cualquier valor
  /// ausente o fuera de los aprobados se lee como Media.
  static String normalizarPrioridad(Object? valor) {
    return prioridades.contains(valor) ? valor as String : prioridadPorDefecto;
  }

  factory Incidencia.desdeJson(Map<String, dynamic> m) {
    return Incidencia(
      id: m['id']?.toString() ?? '',
      titulo: m['titulo']?.toString() ?? '',
      descripcion: m['descripcion']?.toString() ?? '',
      cliente: m['cliente']?.toString() ?? '',
      categoria: m['categoria']?.toString() ?? 'Software',
      estado: m['estado']?.toString() ?? 'Pendiente',
      fecha: m['fecha']?.toString() ?? '',
      prioridad: normalizarPrioridad(m['prioridad']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'cliente': cliente,
      'categoria': categoria,
      'estado': estado,
      'fecha': fecha,
      'prioridad': prioridad,
    };
  }
}
