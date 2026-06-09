// Modelos del contenido interactivo que manda el agente: opciones (botones),
// campos de formulario, e ítems del resumen.
//
// Los parsers son tolerantes a varias formas de JSON porque el shape exacto
// del backend puede variar; ante la duda, conservan el texto crudo.

/// Tipo de campo de un formulario dinámico (evento `pedir_campos_multiples`).
///
/// Enum propio (no reusa el de tramite.dart) para no tocar el modelo generado
/// con json_serializable y para soportar TEXTAREA, que el agente sí usa.
///
/// Contrato v1.0: tipos válidos = TEXT, NUMBER, DATE, SELECT, FILE, TEXTAREA.
/// NO existe CHECKBOX (para booleano se usa SELECT con ["Sí", "No"]).
enum TipoCampoDinamico { text, number, textarea, date, select, file, desconocido }

TipoCampoDinamico tipoCampoDinamicoFrom(String? raw) {
  switch (raw?.toUpperCase()) {
    case 'TEXT':
      return TipoCampoDinamico.text;
    case 'NUMBER':
      return TipoCampoDinamico.number;
    case 'TEXTAREA':
      return TipoCampoDinamico.textarea;
    case 'DATE':
      return TipoCampoDinamico.date;
    case 'SELECT':
      return TipoCampoDinamico.select;
    case 'FILE':
      return TipoCampoDinamico.file;
    default:
      return TipoCampoDinamico.desconocido;
  }
}

List<String> _aListaDeStrings(dynamic v) {
  if (v is List) return v.map((e) => e.toString()).toList();
  return const [];
}

/// Una opción/botón (evento `mostrar_opciones`).
class OpcionAgente {
  /// Lo que ve el usuario en el botón.
  final String etiqueta;

  /// Lo que se le manda al agente al elegirla.
  final String valor;

  const OpcionAgente({required this.etiqueta, required this.valor});

  factory OpcionAgente.fromAny(dynamic raw) {
    if (raw is String) return OpcionAgente(etiqueta: raw, valor: raw);
    if (raw is Map) {
      final m = raw.cast<String, dynamic>();
      final et = (m['etiqueta'] ?? m['label'] ?? m['texto'] ?? m['valor'] ?? m['value'] ?? '')
          .toString();
      final va = (m['valor'] ?? m['value'] ?? m['etiqueta'] ?? m['label'] ?? et).toString();
      return OpcionAgente(etiqueta: et, valor: va);
    }
    final s = raw.toString();
    return OpcionAgente(etiqueta: s, valor: s);
  }
}

/// Un campo del formulario dinámico (evento `pedir_campos_multiples`).
class CampoDinamico {
  final String nombre;
  final String etiqueta;
  final TipoCampoDinamico tipo;
  final bool requerido;

  /// Opciones para campos SELECT.
  final List<String> opciones;

  /// MIME types aceptados para campos FILE (ej: ["image/*", "application/pdf"]).
  final List<String> tiposAceptados;

  const CampoDinamico({
    required this.nombre,
    required this.etiqueta,
    required this.tipo,
    required this.requerido,
    this.opciones = const [],
    this.tiposAceptados = const [],
  });

  factory CampoDinamico.fromJson(Map<String, dynamic> j) {
    final nombre = (j['nombre'] ?? '').toString();
    return CampoDinamico(
      nombre: nombre,
      etiqueta: (j['etiqueta'] ?? j['label'] ?? nombre).toString(),
      tipo: tipoCampoDinamicoFrom(j['tipo'] as String?),
      requerido: (j['requerido'] ?? j['required'] ?? false) == true,
      opciones: _aListaDeStrings(j['opciones'] ?? j['options']),
      tiposAceptados: _aListaDeStrings(j['tiposAceptados'] ?? j['tipos_aceptados']),
    );
  }
}

/// Una fila del resumen (evento `mostrar_resumen`).
class ItemResumen {
  final String etiqueta;
  final String valor;

  const ItemResumen({required this.etiqueta, required this.valor});
}
