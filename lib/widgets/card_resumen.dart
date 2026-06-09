import 'package:flutter/material.dart';
import 'package:tramites_app/models/mensaje_chat.dart';

/// Card de confirmación con todos los datos antes de enviar
/// (evento `mostrar_resumen`).
class CardResumen extends StatelessWidget {
  final MensajeChat mensaje;
  final VoidCallback onConfirmar;
  final VoidCallback onModificar;

  const CardResumen({
    super.key,
    required this.mensaje,
    required this.onConfirmar,
    required this.onModificar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final deshabilitado = mensaje.respondido;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.92,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📋 ', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: Text(
                    mensaje.titulo ?? 'Vamos a enviar',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                  ),
                ),
              ],
            ),
            if (mensaje.contenido.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                mensaje.contenido,
                style: TextStyle(color: colorScheme.onPrimaryContainer),
              ),
            ],
            const SizedBox(height: 12),
            for (final item in mensaje.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.etiqueta.isNotEmpty)
                      Text(
                        '${item.etiqueta}: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        item.valor,
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            for (final archivo in mensaje.archivos)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '📎 $archivo ✓',
                  style: TextStyle(color: colorScheme.onPrimaryContainer),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: deshabilitado ? null : onModificar,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Modificar'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: deshabilitado ? null : onConfirmar,
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Confirmar y enviar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
