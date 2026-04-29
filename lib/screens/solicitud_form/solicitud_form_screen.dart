import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tramites_app/models/tramite.dart';
import 'package:tramites_app/providers/tramites_provider.dart';

class SolicitudFormScreen extends StatefulWidget {
  final String tramiteId;
  final String formularioSolicitanteId;
  final String tramiteNombre;

  const SolicitudFormScreen({
    super.key,
    required this.tramiteId,
    required this.formularioSolicitanteId,
    required this.tramiteNombre,
  });

  @override
  State<SolicitudFormScreen> createState() => _SolicitudFormScreenState();
}

class _SolicitudFormScreenState extends State<SolicitudFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _valores = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<TramitesProvider>()
          .loadFormulario(widget.formularioSolicitanteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TramitesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.tramiteNombre.isNotEmpty
              ? widget.tramiteNombre
              : 'Nueva solicitud',
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: _buildCuerpo(provider),
    );
  }

  Widget _buildCuerpo(TramitesProvider provider) {
    if (provider.isLoadingFormulario) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorFormulario != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                provider.errorFormulario!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context
                    .read<TramitesProvider>()
                    .loadFormulario(widget.formularioSolicitanteId),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final formulario = provider.formulario;
    if (formulario == null) return const SizedBox.shrink();

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (formulario.descripcion != null &&
              formulario.descripcion!.isNotEmpty) ...[
            Text(
              formulario.descripcion!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
          ],
          ...formulario.campos.map(
            (campo) => _CampoWidget(
              campo: campo,
              valor: _valores[campo.nombre] ?? '',
              onChanged: (v) => setState(() => _valores[campo.nombre] = v),
            ),
          ),
          const SizedBox(height: 8),
          if (provider.errorSubmit != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                provider.errorSubmit!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: provider.isSubmitting ? null : _enviar,
            child: provider.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enviar solicitud'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TramitesProvider>();
    final formulario = provider.formulario;
    if (formulario == null) return;

    final respuestas = formulario.campos
        .map((c) => {
              'nombreCampo': c.nombre,
              'valor': _valores[c.nombre] ?? '',
            })
        .toList();

    final result = await provider.createSolicitud(
      tramiteId: widget.tramiteId,
      respuestas: respuestas,
    );

    if (result != null && mounted) {
      context.go('/solicitudes');
    }
  }
}

// ---------------------------------------------------------------------------
// Widgets de campo
// ---------------------------------------------------------------------------

class _CampoWidget extends StatelessWidget {
  final CampoFormulario campo;
  final String valor;
  final ValueChanged<String> onChanged;

  const _CampoWidget({
    required this.campo,
    required this.valor,
    required this.onChanged,
  });

  String get _etiqueta => campo.etiqueta ?? campo.nombre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: switch (campo.tipo) {
        TipoCampo.select => _SelectField(
            etiqueta: _etiqueta,
            opciones: campo.opciones,
            valor: valor,
            requerido: campo.requerido,
            onChanged: onChanged,
          ),
        TipoCampo.checkbox => _CheckboxField(
            etiqueta: _etiqueta,
            valor: valor,
            onChanged: onChanged,
          ),
        TipoCampo.date => _DateField(
            etiqueta: _etiqueta,
            valor: valor,
            requerido: campo.requerido,
            onChanged: onChanged,
          ),
        _ => _TextInputField(
            etiqueta: _etiqueta,
            tipo: campo.tipo,
            valor: valor,
            requerido: campo.requerido,
            onChanged: onChanged,
          ),
      },
    );
  }
}

class _TextInputField extends StatelessWidget {
  final String etiqueta;
  final TipoCampo tipo;
  final String valor;
  final bool requerido;
  final ValueChanged<String> onChanged;

  const _TextInputField({
    required this.etiqueta,
    required this.tipo,
    required this.valor,
    required this.requerido,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: valor,
      keyboardType:
          tipo == TipoCampo.number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: requerido ? '$etiqueta *' : etiqueta,
        border: const OutlineInputBorder(),
      ),
      validator: requerido
          ? (v) =>
              (v == null || v.trim().isEmpty) ? 'Campo requerido' : null
          : null,
      onChanged: onChanged,
    );
  }
}

class _SelectField extends StatelessWidget {
  final String etiqueta;
  final List<String> opciones;
  final String valor;
  final bool requerido;
  final ValueChanged<String> onChanged;

  const _SelectField({
    required this.etiqueta,
    required this.opciones,
    required this.valor,
    required this.requerido,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final current = opciones.contains(valor) ? valor : null;
    return DropdownButtonFormField<String>(
      value: current,
      decoration: InputDecoration(
        labelText: requerido ? '$etiqueta *' : etiqueta,
        border: const OutlineInputBorder(),
      ),
      items: opciones
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      validator:
          requerido ? (v) => v == null ? 'Selecciona una opción' : null : null,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _CheckboxField extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final ValueChanged<String> onChanged;

  const _CheckboxField({
    required this.etiqueta,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(etiqueta),
      value: valor == 'true',
      onChanged: (v) => onChanged((v ?? false).toString()),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

class _DateField extends StatefulWidget {
  final String etiqueta;
  final String valor;
  final bool requerido;
  final ValueChanged<String> onChanged;

  const _DateField({
    required this.etiqueta,
    required this.valor,
    required this.requerido,
    required this.onChanged,
  });

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.valor);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.requerido ? '${widget.etiqueta} *' : widget.etiqueta,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      validator: widget.requerido
          ? (v) =>
              (v == null || v.trim().isEmpty) ? 'Campo requerido' : null
          : null,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          final formatted =
              '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          _controller.text = formatted;
          widget.onChanged(formatted);
        }
      },
    );
  }
}
