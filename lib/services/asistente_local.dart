import 'package:tramites_app/models/tramite.dart';

/// Contrato del asistente local. Desacopla la lógica del motor/modelo concreto:
/// hoy lo implementa [AsistenteLocalGemma] (flutter_gemma), mañana podría ser otro.
abstract class AsistenteLocal {
  /// ¿El modelo está cargado y listo para responder?
  bool get listo;

  /// Carga el modelo en RAM (idempotente). Llamar al entrar al chat (precarga).
  Future<void> preparar();

  /// Responde al mensaje del usuario en streaming (tokens en lenguaje natural).
  /// Al final puede incluir el marcador con el número del trámite recomendado;
  /// el consumidor usa [limpiarTextoAsistente] para mostrar y
  /// [extraerNumeroTramite] al terminar.
  Stream<String> responder(String mensaje, List<TramiteDisponible> catalogo);
}

// --- Marcador oculto: [[N]] -------------------------------------------------
// N = número del trámite en la lista numerada del prompt. Usamos un NÚMERO (no
// el id largo) porque un modelo chico lo reproduce de forma confiable. El
// usuario nunca lo ve: sirve para saber qué trámite/formulario abrir.

final RegExp _reMarcador = RegExp(r'\[\[\s*(\d{1,3})\s*\]\]');

/// Número (1-based) del trámite recomendado en el marcador, o null si no hay.
int? extraerNumeroTramite(String texto) {
  final m = _reMarcador.firstMatch(texto);
  return m != null ? int.tryParse(m.group(1)!) : null;
}

/// Limpia el texto para mostrar: saca el marcador, cualquier cola parcial "[[…"
/// (clave durante el streaming, para que no parpadee), un prefijo de rol que el
/// modelo a veces copia ("Asistente:"), y espacios repetidos.
String limpiarTextoAsistente(String texto) {
  var t = texto.replaceAll(_reMarcador, '');
  final i = t.indexOf('[[');
  if (i != -1) t = t.substring(0, i);
  t = t.trim();
  t = t.replaceFirst(
    RegExp(r'^(asistente|persona|usuario)\s*:\s*', caseSensitive: false),
    '',
  );
  t = t.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
  return t.trim();
}
