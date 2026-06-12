import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:tramites_app/data/local/modelo_local_manager.dart';
import 'package:tramites_app/models/tramite.dart';
import 'package:tramites_app/services/asistente_local.dart';

/// Implementación del asistente local con flutter_gemma (Gemma 3 1B on-device).
///
/// Toda la dependencia del motor vive acá: si mañana se cambia de modelo o de
/// engine, se toca solo esta clase (y la config en [ModeloLocalManager]).
class AsistenteLocalGemma implements AsistenteLocal {
  final ModeloLocalManager _manager;

  AsistenteLocalGemma(this._manager);

  @override
  bool get listo => _manager.listo;

  @override
  Future<void> preparar() => _manager.cargar();

  @override
  Stream<String> responder(
    String mensaje,
    List<TramiteDisponible> catalogo,
  ) async* {
    final modelo = _manager.modelo;
    if (modelo == null) {
      throw StateError('El modelo no está cargado.');
    }

    // Chat nuevo por consulta → contexto limpio + system prompt actualizado.
    // Usamos la API de chat (no la de sesión cruda): formatea bien el turno del
    // asistente y el modelo CIERRA su respuesta solo (sin cortarse por límite).
    final chat = await modelo.createChat(
      temperature: 0.3, // foco/consistencia para recomendar
      topK: 40,
      systemInstruction: _systemPrompt(catalogo),
      supportsFunctionCalls: false, // no usamos tools → evita el formato raro
    );
    // noTool = true → trata el mensaje como turno de usuario normal.
    await chat.addQueryChunk(Message.text(text: mensaje, isUser: true), true);
    await for (final r in chat.generateChatResponseAsync()) {
      if (r is TextResponse) yield r.token;
    }
  }

  /// System prompt dinámico, armado desde el catálogo cacheado real (no hardcode).
  /// La lista va NUMERADA; el modelo recomienda terminando con el número [[N]].
  /// El orden coincide con el del provider (misma lista filtrada por activo).
  String _systemPrompt(List<TramiteDisponible> catalogo) {
    final activos = catalogo.where((t) => t.activo).toList();
    final lista = [
      for (var i = 0; i < activos.length; i++)
        '${i + 1}. ${activos[i].nombre}'
            '${_extra(activos[i])}',
    ].join('\n');

    return '''
Sos el asistente de una app de trámites. Ayudás a la persona a encontrar el trámite que necesita, eligiendo SOLO de esta lista numerada:

$lista

Reglas (respondé en español, breve y amable):
- Si lo que necesita coincide con un trámite de la lista: recomendalo en 1 o 2 frases y terminá con su NÚMERO (el que está al principio de su línea) entre dobles corchetes. Ejemplo de formato: [[2]].
- Si NO coincide con ningún trámite, o es un saludo o algo que no es un trámite: respondé amable que solo ayudás con trámites y pedí que aclare. NO pongas ningún número entre corchetes.
- No inventes trámites. Ante la duda, no recomiendes.

Ejemplos de comportamiento:
- "necesito ayuda para pagar mis estudios" -> recomendás la beca y terminás con su número de la lista, p. ej. [[1]].
- "cuánto está el dólar" -> "Perdoná, solo puedo ayudarte con trámites. ¿Qué gestión necesitás?" (sin número).
- "hola" -> "¡Hola! ¿Qué trámite necesitás hacer?" (sin número).
''';
  }

  /// Descripción + etiquetas de un trámite para la lista del prompt.
  String _extra(TramiteDisponible t) {
    final desc = (t.descripcion ?? '').trim();
    final etiquetas =
        t.etiquetas.isNotEmpty ? ' [${t.etiquetas.join(', ')}]' : '';
    return '${desc.isNotEmpty ? ' — $desc' : ''}$etiquetas';
  }
}
