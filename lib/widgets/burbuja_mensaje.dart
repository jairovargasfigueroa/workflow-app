import 'package:flutter/material.dart';
import 'package:tramites_app/models/mensaje_chat.dart';

/// Burbuja de un mensaje del chat del agente. Alinea a la derecha los mensajes
/// del usuario y a la izquierda los del agente.
class BurbujaMensaje extends StatelessWidget {
  final MensajeChat mensaje;

  const BurbujaMensaje({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final esUsuario = mensaje.esUsuario;
    final esError = mensaje.tipo == TipoMensaje.error;

    final esSistema = mensaje.tipo == TipoMensaje.sistema;

    final Color fondo;
    final Color texto;
    if (esError) {
      fondo = colorScheme.errorContainer;
      texto = colorScheme.onErrorContainer;
    } else if (esSistema) {
      fondo = colorScheme.tertiaryContainer;
      texto = colorScheme.onTertiaryContainer;
    } else if (esUsuario) {
      fondo = colorScheme.primary;
      texto = colorScheme.onPrimary;
    } else {
      fondo = colorScheme.surfaceContainerHighest;
      texto = colorScheme.onSurface;
    }

    final radio = Radius.circular(16);
    final bordes = BorderRadius.only(
      topLeft: radio,
      topRight: radio,
      bottomLeft: esUsuario ? radio : const Radius.circular(4),
      bottomRight: esUsuario ? const Radius.circular(4) : radio,
    );

    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: fondo, borderRadius: bordes),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!esUsuario) ...[
              Text(esError ? '⚠️ ' : '🤖 ', style: const TextStyle(fontSize: 14)),
            ],
            Flexible(
              child: Text(
                mensaje.contenido,
                style: TextStyle(color: texto, fontSize: 15, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicador de "el agente está usando una herramienta…" (eventos tool_call).
class IndicadorHerramienta extends StatelessWidget {
  final String nombre;

  const IndicadorHerramienta({super.key, required this.nombre});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Usando $nombre…',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
