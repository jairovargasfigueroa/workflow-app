// Documento que un trámite exige al iniciar la solicitud (el "kit").
// Lo configura el admin en el nodo inicial del flujo.
// Endpoint: GET /api/tramites/{id}/documentos-kit

class DocumentoKit {
  final String nombre;

  /// Formatos aceptados, ej: ["pdf", "jpg"]. Si está vacío, sin restricción.
  final List<String> formatosAceptados;

  final bool obligatorio;

  /// No puede modificarse una vez cerrada la solicitud (informativo por ahora).
  final bool inmutablePostCierre;

  const DocumentoKit({
    required this.nombre,
    this.formatosAceptados = const [],
    this.obligatorio = false,
    this.inmutablePostCierre = false,
  });

  factory DocumentoKit.fromJson(Map<String, dynamic> json) {
    final formatos = json['formatosAceptados'];
    return DocumentoKit(
      nombre: (json['nombre'] ?? '').toString(),
      formatosAceptados: formatos is List
          ? formatos.map((e) => e.toString()).toList()
          : const [],
      obligatorio: json['obligatorio'] == true,
      inmutablePostCierre: json['inmutablePostCierre'] == true,
    );
  }
}
