// Archivo del módulo documental (con permisos).
// GET /api/archivos/solicitud/{solicitudId} → List<ArchivoResponse>

class ArchivoResponse {
  final String id;
  final String? solicitudId;
  final String nombre;

  /// Extensión, ej: "pdf".
  final String? formato;

  /// MIME real, ej: "application/pdf".
  final String? contentType;

  final int tamanoBytes;

  /// Documento del kit al que corresponde (ej: "Cédula").
  final String? campoFormularioOrigen;

  final String? subidoPorNombre;
  final DateTime? fechaSubida;
  final String? estado;

  const ArchivoResponse({
    required this.id,
    this.solicitudId,
    required this.nombre,
    this.formato,
    this.contentType,
    this.tamanoBytes = 0,
    this.campoFormularioOrigen,
    this.subidoPorNombre,
    this.fechaSubida,
    this.estado,
  });

  factory ArchivoResponse.fromJson(Map<String, dynamic> json) {
    return ArchivoResponse(
      id: (json['id'] ?? '').toString(),
      solicitudId: json['solicitudId']?.toString(),
      nombre: (json['nombre'] ?? '').toString(),
      formato: json['formato']?.toString(),
      contentType: json['contentType']?.toString(),
      tamanoBytes: (json['tamanoBytes'] is num)
          ? (json['tamanoBytes'] as num).toInt()
          : int.tryParse('${json['tamanoBytes']}') ?? 0,
      campoFormularioOrigen: json['campoFormularioOrigen']?.toString(),
      subidoPorNombre: json['subidoPorNombre']?.toString(),
      fechaSubida: json['fechaSubida'] is String
          ? DateTime.tryParse(json['fechaSubida'] as String)
          : null,
      estado: json['estado']?.toString(),
    );
  }

  /// Tamaño legible, ej: "23.4 KB".
  String get tamanoLegible {
    if (tamanoBytes <= 0) return '';
    const unidades = ['B', 'KB', 'MB', 'GB'];
    var valor = tamanoBytes.toDouble();
    var i = 0;
    while (valor >= 1024 && i < unidades.length - 1) {
      valor /= 1024;
      i++;
    }
    final txt = i == 0 ? valor.toStringAsFixed(0) : valor.toStringAsFixed(1);
    return '$txt ${unidades[i]}';
  }
}
