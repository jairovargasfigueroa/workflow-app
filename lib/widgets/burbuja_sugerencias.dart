import 'package:flutter/material.dart';
import 'package:tramites_app/models/mensaje_chat.dart';
import 'package:tramites_app/models/tramite.dart';

/// Burbuja del asistente offline con los trámites sugeridos (botones) + el
/// "Ver todos" como red de seguridad (siempre presente).
class BurbujaSugerencias extends StatelessWidget {
  final MensajeChat mensaje;
  final ValueChanged<TramiteDisponible> onElegir;
  final VoidCallback onVerTodos;

  const BurbujaSugerencias({
    super.key,
    required this.mensaje,
    required this.onElegir,
    required this.onVerTodos,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            for (final tramite in mensaje.tramites)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () => onElegir(tramite),
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(tramite.nombre),
                    ),
                  ),
                ),
              ),
            // Red de seguridad: siempre se puede ver la lista completa.
            TextButton.icon(
              onPressed: onVerTodos,
              icon: const Icon(Icons.list, size: 18),
              label: const Text('Ver todos los trámites'),
            ),
          ],
        ),
      ),
    );
  }
}
