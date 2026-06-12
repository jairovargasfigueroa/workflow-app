import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tramites_app/models/archivo_para_subir.dart';
import 'package:tramites_app/models/documento_kit.dart';
import 'package:tramites_app/models/tramite.dart';
import 'package:tramites_app/providers/conectividad_provider.dart';
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

  /// Archivos del kit elegidos, por nombre de documento. Quedan en disco (path)
  /// hasta que se crea la solicitud y se suben.
  final Map<String, ArchivoParaSubir> _archivos = {};
  String? _errorDocs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TramitesProvider>();
      provider.loadFormulario(widget.formularioSolicitanteId);
      provider.loadDocumentosKit(widget.tramiteId);
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

    final offline = context.watch<ConectividadProvider>().offline;

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
          _buildKit(provider),
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
          if (offline) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_off,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sin conexión: se guardará y se enviará automáticamente al reconectar.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: provider.isSubmitting ? null : _enviar,
            child: provider.isSubmitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(offline ? 'Guardar (se enviará luego)' : 'Enviar solicitud'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _elegirArchivo(DocumentoKit doc) async {
    final exts = doc.formatosAceptados
        .map((e) => e.toLowerCase().replaceAll('.', '').trim())
        .where((e) => RegExp(r'^[a-z0-9]+$').hasMatch(e))
        .toList();

    final result = await FilePicker.platform.pickFiles(
      type: exts.isEmpty ? FileType.any : FileType.custom,
      allowedExtensions: exts.isEmpty ? null : exts,
    );
    if (result == null || result.files.isEmpty) return;

    final f = result.files.first;
    if (f.path == null) return;

    setState(() {
      _archivos[doc.nombre] = ArchivoParaSubir(
        campoFormulario: doc.nombre,
        path: f.path!,
        nombre: f.name,
        tamanoBytes: f.size,
        extension: (f.extension ?? '').toLowerCase(),
      );
      _errorDocs = null;
    });
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TramitesProvider>();
    final formulario = provider.formulario;
    if (formulario == null) return;

    // Validar documentos obligatorios del kit.
    final faltantes = provider.documentosKit
        .where((d) => d.obligatorio && !_archivos.containsKey(d.nombre))
        .map((d) => d.nombre)
        .toList();
    if (faltantes.isNotEmpty) {
      setState(() => _errorDocs = 'Faltan documentos: ${faltantes.join(', ')}');
      return;
    }
    setState(() => _errorDocs = null);

    final offline = context.read<ConectividadProvider>().offline;
    final respuestas = formulario.campos
        .map((c) => {
              'nombreCampo': c.nombre,
              'valor': _valores[c.nombre] ?? '',
            })
        .toList();

    // Encola (funciona online y offline); el sync la sube enseguida si hay red.
    final ok = await provider.crearSolicitudConKit(
      tramiteId: widget.tramiteId,
      tramiteNombre: widget.tramiteNombre,
      respuestas: respuestas,
      archivos: _archivos.values.toList(),
    );

    if (!mounted) return;
    if (ok) {
      final router = GoRouter.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            offline
                ? 'Sin conexión: se guardó y se enviará al reconectar.'
                : 'Enviando tu solicitud…',
          ),
        ),
      );
      // Sacar el formulario de la pila de Trámites (sino queda al volver a esa
      // pestaña) y cambiar a Mis solicitudes.
      if (router.canPop()) router.pop();
      router.go('/solicitudes');
    }
  }

  /// Sección "Documentos requeridos" (kit del trámite). Por ahora solo muestra
  /// qué documentos pide; la selección/subida real es el paso siguiente.
  Widget _buildKit(TramitesProvider provider) {
    if (provider.isLoadingKit) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final kit = provider.documentosKit;
    if (kit.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Documentos requeridos',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Adjuntá los documentos requeridos para este trámite.',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        ...kit.map(
          (d) => _KitDocumentoTile(
            documento: d,
            archivo: _archivos[d.nombre],
            deshabilitado: provider.isSubmitting,
            onElegir: () => _elegirArchivo(d),
            onQuitar: () => setState(() => _archivos.remove(d.nombre)),
          ),
        ),
        if (_errorDocs != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorDocs!,
            style: TextStyle(color: colorScheme.error, fontSize: 13),
          ),
        ],
      ],
    );
  }
}

class _KitDocumentoTile extends StatelessWidget {
  final DocumentoKit documento;
  final ArchivoParaSubir? archivo;
  final bool deshabilitado;
  final VoidCallback onElegir;
  final VoidCallback onQuitar;

  const _KitDocumentoTile({
    required this.documento,
    required this.archivo,
    required this.deshabilitado,
    required this.onElegir,
    required this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatos = documento.formatosAceptados.isEmpty
        ? null
        : 'Formatos: ${documento.formatosAceptados.join(', ')}';
    final elegido = archivo != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  elegido ? Icons.check_circle : Icons.description_outlined,
                  color: elegido ? Colors.green : colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        documento.obligatorio
                            ? '${documento.nombre} *'
                            : documento.nombre,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (formatos != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          formatos,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (!elegido)
                  OutlinedButton.icon(
                    onPressed: deshabilitado ? null : onElegir,
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text('Adjuntar'),
                  ),
              ],
            ),
            if (elegido) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        archivo!.tamanoLegible.isEmpty
                            ? archivo!.nombre
                            : '${archivo!.nombre} · ${archivo!.tamanoLegible}',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Quitar',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: deshabilitado ? null : onQuitar,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
      initialValue: current,
      decoration: InputDecoration(
        labelText: requerido ? '$etiqueta *' : etiqueta,
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
