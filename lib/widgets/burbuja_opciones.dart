import 'package:flutter/material.dart';
import 'package:tramites_app/models/contenido_interactivo.dart';
import 'package:tramites_app/models/mensaje_chat.dart';

/// Burbuja del agente con botones de opción (evento `mostrar_opciones`).
/// Al tocar un botón se notifica con [onElegir] y los botones se deshabilitan.
class BurbujaOpciones extends StatelessWidget {
  final MensajeChat mensaje;
  final ValueChanged<OpcionAgente> onElegir;

  const BurbujaOpciones({
    super.key,
    required this.mensaje,
    required this.onElegir,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final deshabilitado = mensaje.respondido;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mensaje.contenido.isNotEmpty) ...[
              Text(
                '🤖 ${mensaje.contenido}',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final opcion in mensaje.opciones)
                  FilledButton.tonal(
                    onPressed:
                        deshabilitado ? null : () => onElegir(opcion),
                    child: Text(opcion.etiqueta),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
