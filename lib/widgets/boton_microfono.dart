import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Botón de dictado por voz para el input del chat (speech_to_text, on-device).
///
/// Comportamiento (según brief de voz):
/// - Toca 🎤 → escucha en español; el transcript aparece EN VIVO en el campo.
/// - NO auto-envía: el usuario revisa y toca Enviar.
/// - Vuelve a tocar → cancela la escucha.
/// - Si ya había texto, concatena con un espacio.
/// - Si el chat se bloquea (procesando) o se sale de la pantalla, corta.
class BotonMicrofono extends StatefulWidget {
  final TextEditingController controller;

  /// false mientras el chat procesa una respuesta (deshabilita y corta).
  final bool habilitado;

  /// Notifica al padre para mostrar el indicador "Escuchando…".
  final ValueChanged<bool> onEscuchandoCambio;

  const BotonMicrofono({
    super.key,
    required this.controller,
    required this.habilitado,
    required this.onEscuchandoCambio,
  });

  @override
  State<BotonMicrofono> createState() => _BotonMicrofonoState();
}

class _BotonMicrofonoState extends State<BotonMicrofono> {
  final SpeechToText _speech = SpeechToText();
  bool _disponible = false;
  bool _escuchando = false;

  /// Texto que había en el campo antes de empezar a dictar (para concatenar).
  String _textoBase = '';
  String? _localeId;

  @override
  void didUpdateWidget(BotonMicrofono oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el chat se bloquea mientras dictábamos, cortamos.
    if (!widget.habilitado && _escuchando) {
      _detener();
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  Future<void> _inicializar() async {
    try {
      _disponible = await _speech.initialize(
        onStatus: _onStatus,
        onError: _onError,
      );
      if (_disponible) {
        final locales = await _speech.locales();
        final es = locales
            .where((l) => l.localeId.toLowerCase().startsWith('es'))
            .toList();
        _localeId = es.isNotEmpty ? es.first.localeId : 'es_ES';
      }
    } catch (_) {
      _disponible = false;
    }
  }

  void _onStatus(String status) {
    final escuchando = status == 'listening';
    if (escuchando != _escuchando && mounted) {
      setState(() => _escuchando = escuchando);
      widget.onEscuchandoCambio(escuchando);
    }
  }

  void _onError(SpeechRecognitionError error) {
    // Timeouts / "no match" no molestan al usuario; solo cortamos el estado.
    if (_escuchando && mounted) {
      setState(() => _escuchando = false);
      widget.onEscuchandoCambio(false);
    }
  }

  Future<void> _toggle() async {
    if (_escuchando) {
      await _detener();
    } else {
      await _empezar();
    }
  }

  Future<void> _empezar() async {
    if (!_disponible) {
      await _inicializar();
      if (!_disponible) {
        final err = _speech.lastError;
        final esPermiso = err != null &&
            (err.errorMsg.contains('permission') ||
                err.errorMsg.contains('denied'));
        _mostrar(esPermiso
            ? 'Permiso de micrófono denegado. Activalo en Ajustes para dictar.'
            : 'El dictado por voz no está disponible en este dispositivo.');
        return;
      }
    }

    _textoBase = widget.controller.text.trimRight();
    await _speech.listen(
      onResult: _onResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        listenMode: ListenMode.dictation,
        cancelOnError: true,
        localeId: _localeId,
      ),
    );
    if (mounted) {
      setState(() => _escuchando = true);
      widget.onEscuchandoCambio(true);
    }
  }

  Future<void> _detener() async {
    await _speech.stop();
    if (mounted) {
      setState(() => _escuchando = false);
      widget.onEscuchandoCambio(false);
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    final dicho = result.recognizedWords;
    final sep = _textoBase.isEmpty ? '' : '$_textoBase ';
    final texto = '$sep$dicho';
    widget.controller.value = TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }

  void _mostrar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final habilitado = widget.habilitado;

    if (_escuchando) {
      return IconButton.filled(
        tooltip: 'Detener',
        icon: const Icon(Icons.stop),
        style: IconButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        onPressed: habilitado ? _toggle : null,
      );
    }

    return IconButton.filledTonal(
      tooltip: 'Dictar por voz',
      icon: const Icon(Icons.mic_none),
      onPressed: habilitado ? _toggle : null,
    );
  }
}
