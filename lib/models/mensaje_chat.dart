import 'package:tramites_app/models/contenido_interactivo.dart';

/// Quién emite el mensaje en el chat.
enum RolMensaje { usuario, agente }

/// Cómo se renderiza la burbuja/elemento del chat.
enum TipoMensaje {
  texto, // burbuja de texto normal
  error, // burbuja de error
  sistema, // aviso del sistema (ej: "Solicitud #1234 creada")
  opciones, // botones (mostrar_opciones)
  formulario, // formulario dinámico (pedir_campos_multiples)
  resumen, // card de confirmación (mostrar_resumen)
}

/// Un elemento visible en la conversación del agente.
///
/// [contenido] es mutable a propósito: los eventos `texto` del SSE llegan en
/// fragmentos que se acumulan en la misma burbuja del agente. Los campos
/// interactivos (opciones, campos, items) se usan según el [tipo].
class MensajeChat {
  final String id;
  final RolMensaje rol;
  final TipoMensaje tipo;
  String contenido;

  /// Botones (tipo == opciones).
  final List<OpcionAgente> opciones;

  /// Título de formulario o resumen.
  final String? titulo;

  /// Campos del formulario (tipo == formulario).
  final List<CampoDinamico> campos;

  /// Filas del resumen (tipo == resumen).
  final List<ItemResumen> items;

  /// Nombres de archivos adjuntos a mostrar en el resumen (tipo == resumen).
  final List<String> archivos;

  /// Errores por campo, aplicados al formulario tras `pedir_correcciones`.
  Map<String, String> errores;

  /// Si el usuario ya interactuó con este elemento (deshabilita botones/inputs).
  bool respondido;

  MensajeChat({
    required this.id,
    required this.rol,
    required this.tipo,
    this.contenido = '',
    this.opciones = const [],
    this.titulo,
    this.campos = const [],
    this.items = const [],
    this.archivos = const [],
    Map<String, String>? errores,
    this.respondido = false,
  }) : errores = errores ?? <String, String>{};

  bool get esUsuario => rol == RolMensaje.usuario;
}
