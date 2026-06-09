import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tramites_app/models/mensaje_chat.dart';
import 'package:tramites_app/providers/agente_tramites_provider.dart';
import 'package:tramites_app/widgets/boton_microfono.dart';
import 'package:tramites_app/widgets/burbuja_mensaje.dart';
import 'package:tramites_app/widgets/burbuja_opciones.dart';
import 'package:tramites_app/widgets/card_resumen.dart';
import 'package:tramites_app/widgets/formulario_dinamico.dart';

/// Pantalla principal del agente conversacional de trámites (rol SOLICITANTE).
///
/// Chat con texto + voz (dictado), streaming del agente, indicador de
/// herramienta y UI dinámica (opciones, formulario, resumen).
class ChatAgenteScreen extends StatefulWidget {
  const ChatAgenteScreen({super.key});

  @override
  State<ChatAgenteScreen> createState() => _ChatAgenteScreenState();
}

class _ChatAgenteScreenState extends State<ChatAgenteScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  String? _ultimoErrorMostrado;
  bool _escuchando = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _enviar() {
    final texto = _inputController.text;
    if (texto.trim().isEmpty) return;
    _inputController.clear();
    context.read<AgenteTramitesProvider>().enviar(texto);
    _irAlFinal();
  }

  void _irAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AgenteTramitesProvider>();

    // Auto-scroll y SnackBar de error fuera del árbol de build.
    _irAlFinal();
    if (provider.error != null && provider.error != _ultimoErrorMostrado) {
      _ultimoErrorMostrado = provider.error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error!)),
        );
        context.read<AgenteTramitesProvider>().limpiarError();
        _ultimoErrorMostrado = null;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente de trámites'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            tooltip: 'Nueva conversación',
            icon: const Icon(Icons.refresh),
            onPressed: provider.enviando
                ? null
                : () => context.read<AgenteTramitesProvider>().reiniciar(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: provider.estaVacio
                ? const _Bienvenida()
                : _buildLista(provider),
          ),
          if (_escuchando) const _BannerEscuchando(),
          _BarraEntrada(
            controller: _inputController,
            enviando: provider.enviando,
            onEnviar: _enviar,
            onEscuchando: (v) => setState(() => _escuchando = v),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(AgenteTramitesProvider provider) {
    final mensajes = provider.mensajes;
    final mostrarTool = provider.toolActiva != null;
    final itemCount = mensajes.length + (mostrarTool ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= mensajes.length) {
          return IndicadorHerramienta(nombre: provider.toolActiva!);
        }
        return _buildMensaje(context, mensajes[index]);
      },
    );
  }

  Widget _buildMensaje(BuildContext context, MensajeChat mensaje) {
    final provider = context.read<AgenteTramitesProvider>();
    switch (mensaje.tipo) {
      case TipoMensaje.opciones:
        return BurbujaOpciones(
          mensaje: mensaje,
          onElegir: (opcion) => provider.elegirOpcion(mensaje, opcion),
        );
      case TipoMensaje.formulario:
        return FormularioDinamico(
          // key por id: preserva el estado del form al re-renderizar la lista.
          key: ValueKey(mensaje.id),
          mensaje: mensaje,
          onEnviar: (datos, archivos) =>
              provider.enviarFormulario(mensaje, datos, archivos),
        );
      case TipoMensaje.resumen:
        return CardResumen(
          mensaje: mensaje,
          onConfirmar: () => provider.confirmarResumen(mensaje),
          onModificar: () => provider.modificarResumen(mensaje),
        );
      case TipoMensaje.texto:
      case TipoMensaje.error:
      case TipoMensaje.sistema:
        return BurbujaMensaje(mensaje: mensaje);
    }
  }
}

class _Bienvenida extends StatelessWidget {
  const _Bienvenida();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🤖', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              '¡Hola! Soy tu asistente para iniciar trámites.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contame qué necesitás y te recomiendo el trámite correcto.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarraEntrada extends StatelessWidget {
  final TextEditingController controller;
  final bool enviando;
  final VoidCallback onEnviar;
  final ValueChanged<bool> onEscuchando;

  const _BarraEntrada({
    required this.controller,
    required this.enviando,
    required this.onEnviar,
    required this.onEscuchando,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Micrófono: dictado por voz (entrada primaria).
            BotonMicrofono(
              controller: controller,
              habilitado: !enviando,
              onEscuchandoCambio: onEscuchando,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !enviando,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onEnviar(),
                decoration: InputDecoration(
                  hintText: 'Escribí tu mensaje…',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            enviando
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                : IconButton.filled(
                    icon: const Icon(Icons.send),
                    onPressed: onEnviar,
                  ),
          ],
        ),
      ),
    );
  }
}

/// Indicador "🔴 Escuchando…" que aparece sobre la barra de entrada mientras
/// el dictado por voz está activo. El transcript se ve en vivo en el campo.
class _BannerEscuchando extends StatelessWidget {
  const _BannerEscuchando();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.red.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
          SizedBox(width: 8),
          Text(
            'Escuchando…',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
