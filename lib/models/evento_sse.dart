import 'package:tramites_app/models/contenido_interactivo.dart';

/// Eventos que emite el agente de trámites por el stream SSE
/// (POST /api/agente-tramites/chat).
///
/// El backend manda objetos `{ "tipo": "...", ... }`. El campo `tipo`
/// discrimina cómo renderizar el evento en la UI.
enum TipoEventoSSE {
  /// Primer evento cuando la sesión es nueva: trae el sesionId asignado.
  sesion,

  /// El agente empezó a usar una herramienta (indicador visual).
  toolCall,

  /// La herramienta devolvió resultado (oculta el indicador).
  toolResult,

  /// Fragmento de texto del agente (se acumula en una burbuja).
  texto,

  /// Botones para que el usuario elija una opción.
  mostrarOpciones,

  /// Formulario completo: todos los campos de una sola vez.
  pedirCamposMultiples,

  /// Errores de validación sobre campos específicos.
  pedirCorrecciones,

  /// Card de confirmación con todos los datos antes de enviar.
  mostrarResumen,

  /// La solicitud fue creada por el micro (trae solicitudId / numero).
  solicitudCreada,

  /// El agente pide que Flutter suba los archivos guardados localmente.
  subirArchivos,

  /// Fin del stream para este mensaje.
  fin,

  /// Error reportado por el agente.
  error,

  /// Tipo no reconocido (defensivo: backends futuros).
  desconocido,
}

TipoEventoSSE _tipoFromString(String? raw) {
  switch (raw) {
    // Contrato v1.0 — camelCase.
    case 'sesion':
      return TipoEventoSSE.sesion;
    case 'texto':
      return TipoEventoSSE.texto;
    case 'toolCall':
      return TipoEventoSSE.toolCall;
    case 'toolResult':
      return TipoEventoSSE.toolResult;
    case 'mostrarOpciones':
      return TipoEventoSSE.mostrarOpciones;
    case 'pedirCamposMultiples':
      return TipoEventoSSE.pedirCamposMultiples;
    case 'pedirCorrecciones':
      return TipoEventoSSE.pedirCorrecciones;
    case 'mostrarResumen':
      return TipoEventoSSE.mostrarResumen;
    case 'solicitudCreada':
      return TipoEventoSSE.solicitudCreada;
    case 'subirArchivos':
      return TipoEventoSSE.subirArchivos;
    case 'fin':
      return TipoEventoSSE.fin;
    case 'error':
      return TipoEventoSSE.error;
    default:
      return TipoEventoSSE.desconocido;
  }
}

/// Un evento SSE ya tipado. Conserva el payload crudo en [data] para que las
/// fases siguientes (formulario, opciones, resumen, archivos) lean los campos
/// que necesiten sin tener que cambiar este modelo.
class EventoSSE {
  final TipoEventoSSE tipo;
  final Map<String, dynamic> data;

  const EventoSSE({required this.tipo, required this.data});

  factory EventoSSE.fromJson(Map<String, dynamic> json) => EventoSSE(
        tipo: _tipoFromString(json['tipo'] as String?),
        data: json,
      );

  // --- Accesos de conveniencia usados en Fase 1 -------------------------

  /// Texto del agente (evento `texto`).
  String? get contenido => data['contenido'] as String?;

  /// Nombre de la herramienta (evento `tool_call`).
  String? get nombre => data['nombre'] as String?;

  /// Mensaje de error legible (evento `error`).
  String? get mensajeError =>
      (data['mensaje'] ?? data['error'] ?? data['detalle']) as String?;

  // --- Accesos para Fase 2 (UI interactiva) -----------------------------

  /// sesionId asignado por el micro (evento `sesion`).
  String? get sesionId => data['sesionId']?.toString();

  /// Título de un formulario o resumen.
  String? get titulo => data['titulo'] as String?;

  /// Texto introductorio que a veces acompaña opciones/formulario/resumen.
  String? get textoIntro =>
      (data['contenido'] ?? data['mensaje'] ?? data['texto']) as String?;

  /// Opciones/botones (evento `mostrar_opciones`).
  List<OpcionAgente> get opciones {
    final raw = data['opciones'] ?? data['options'];
    if (raw is List) return raw.map(OpcionAgente.fromAny).toList();
    return const [];
  }

  /// Campos del formulario (evento `pedir_campos_multiples`).
  List<CampoDinamico> get campos {
    final raw = data['campos'] ?? data['fields'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((m) => CampoDinamico.fromJson(m.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  /// Errores por campo (evento `pedir_correcciones`).
  Map<String, String> get errores {
    final raw = data['errores'] ?? data['correcciones'] ?? data['errors'];
    final result = <String, String>{};
    if (raw is Map) {
      raw.forEach((k, v) => result[k.toString()] = v.toString());
    } else if (raw is List) {
      for (final it in raw) {
        if (it is Map) {
          final campo = (it['campo'] ?? it['nombre'] ?? '').toString();
          final msg = (it['mensaje'] ?? it['error'] ?? '').toString();
          if (campo.isNotEmpty) result[campo] = msg;
        }
      }
    }
    return result;
  }

  /// Filas del resumen (evento `mostrar_resumen`).
  List<ItemResumen> get itemsResumen {
    final result = <ItemResumen>[];
    final items = data['items'] ?? data['filas'];
    if (items is List) {
      for (final it in items) {
        if (it is Map) {
          final m = it.cast<String, dynamic>();
          result.add(ItemResumen(
            etiqueta: (m['etiqueta'] ?? m['label'] ?? m['campo'] ?? '').toString(),
            valor: (m['valor'] ?? m['value'] ?? '').toString(),
          ));
        } else {
          result.add(ItemResumen(etiqueta: '', valor: it.toString()));
        }
      }
      return result;
    }
    final datos = data['datos'] ?? data['resumen'];
    if (datos is Map) {
      datos.forEach(
        (k, v) => result.add(ItemResumen(etiqueta: k.toString(), valor: v.toString())),
      );
    }
    return result;
  }

  /// Nombres de archivos a mostrar en el resumen (evento `mostrarResumen`).
  List<String> get nombresArchivosResumen {
    final raw = data['archivos'] ?? data['files'];
    if (raw is List) {
      return raw
          .map((e) => e is Map
              ? (e['nombre'] ?? e['campo'] ?? '').toString()
              : e.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  /// ID de la solicitud creada (evento `solicitudCreada`).
  String? get solicitudId => (data['solicitudId'] ?? data['solicitud_id'])?.toString();

  /// Número visible de la solicitud (evento `solicitud_creada`).
  String? get numeroSolicitud =>
      (data['numero'] ?? data['numeroSolicitud'] ?? data['numero_solicitud'])?.toString();

  /// Archivos que el agente pide subir (evento `subir_archivos`). Fase 4.
  List<Map<String, dynamic>> get archivosASubir {
    final raw = data['archivos'] ?? data['files'];
    if (raw is List) {
      return raw.whereType<Map>().map((m) => m.cast<String, dynamic>()).toList();
    }
    return const [];
  }

  @override
  String toString() => 'EventoSSE(tipo: $tipo, data: $data)';
}
