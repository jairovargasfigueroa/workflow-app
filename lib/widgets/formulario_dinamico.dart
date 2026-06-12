import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tramites_app/models/archivo_para_subir.dart';
import 'package:tramites_app/models/contenido_interactivo.dart';
import 'package:tramites_app/models/mensaje_chat.dart';

/// Renderiza un formulario completo a partir de los campos que mandó el agente
/// (evento `pedir_campos_multiples`) y, al confirmar, entrega datos + archivos.
///
/// [onEnviar] recibe (datos, archivos). Los campos FILE se eligen acá y se
/// suben después, cuando el agente manda el evento `subir_archivos`.
class FormularioDinamico extends StatefulWidget {
  final MensajeChat mensaje;
  final void Function(
    Map<String, String> datos,
    List<ArchivoParaSubir> archivos,
  ) onEnviar;

  const FormularioDinamico({
    super.key,
    required this.mensaje,
    required this.onEnviar,
  });

  @override
  State<FormularioDinamico> createState() => _FormularioDinamicoState();
}

class _FormularioDinamicoState extends State<FormularioDinamico> {
  final Map<String, TextEditingController> _controllers = {};

  /// Valores de campos no-texto (select, date, checkbox).
  final Map<String, String> _valores = {};

  /// Archivos elegidos para campos FILE (por nombre de campo).
  final Map<String, ArchivoParaSubir> _archivos = {};

  /// Errores de validación local (además de los que manda el server).
  final Map<String, String?> _erroresLocales = {};

  @override
  void initState() {
    super.initState();
    for (final campo in widget.mensaje.campos) {
      if (_esCampoDeTexto(campo.tipo)) {
        _controllers[campo.nombre] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool _esCampoDeTexto(TipoCampoDinamico tipo) =>
      tipo == TipoCampoDinamico.text ||
      tipo == TipoCampoDinamico.textarea ||
      tipo == TipoCampoDinamico.number;

  String _valorDe(CampoDinamico campo) {
    if (_esCampoDeTexto(campo.tipo)) {
      return _controllers[campo.nombre]?.text.trim() ?? '';
    }
    return _valores[campo.nombre] ?? '';
  }

  void _confirmar() {
    _erroresLocales.clear();
    final datos = <String, String>{};
    final archivos = <ArchivoParaSubir>[];
    var hayError = false;

    for (final campo in widget.mensaje.campos) {
      if (campo.tipo == TipoCampoDinamico.file) {
        final archivo = _archivos[campo.nombre];
        if (campo.requerido && archivo == null) {
          _erroresLocales[campo.nombre] = 'Adjuntá este documento';
          hayError = true;
        } else if (archivo != null) {
          archivos.add(archivo);
        }
        continue;
      }

      final valor = _valorDe(campo);
      if (campo.requerido && valor.isEmpty) {
        _erroresLocales[campo.nombre] = 'Este campo es obligatorio';
        hayError = true;
        continue;
      }
      if (valor.isNotEmpty) datos[campo.nombre] = valor;
    }

    if (hayError) {
      setState(() {});
      return;
    }

    widget.onEnviar(datos, archivos);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mensaje = widget.mensaje;
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
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📋 ', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: Text(
                    mensaje.titulo ?? 'Completá los datos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            if (mensaje.contenido.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                mensaje.contenido,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 12),
            for (final campo in mensaje.campos) ...[
              _buildCampo(campo, deshabilitado),
              const SizedBox(height: 14),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: deshabilitado ? null : _confirmar,
                icon: const Icon(Icons.check),
                label: Text(deshabilitado ? 'Enviado' : 'Confirmar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampo(CampoDinamico campo, bool deshabilitado) {
    final errorServer = widget.mensaje.errores[campo.nombre];
    final errorLocal = _erroresLocales[campo.nombre];
    final error = errorLocal ?? errorServer;
    final etiqueta = campo.etiqueta + (campo.requerido ? ' *' : '');

    switch (campo.tipo) {
      case TipoCampoDinamico.text:
        return _textField(campo, etiqueta, error, deshabilitado);
      case TipoCampoDinamico.textarea:
        return _textField(campo, etiqueta, error, deshabilitado, lineas: 3);
      case TipoCampoDinamico.number:
        return _textField(campo, etiqueta, error, deshabilitado, numerico: true);
      case TipoCampoDinamico.select:
        return _selectField(campo, etiqueta, error, deshabilitado);
      case TipoCampoDinamico.date:
        return _dateField(campo, etiqueta, error, deshabilitado);
      case TipoCampoDinamico.file:
        return _fileField(campo, etiqueta, error, deshabilitado);
      case TipoCampoDinamico.desconocido:
        return _textField(campo, etiqueta, error, deshabilitado);
    }
  }

  Widget _textField(
    CampoDinamico campo,
    String etiqueta,
    String? error,
    bool deshabilitado, {
    int lineas = 1,
    bool numerico = false,
  }) {
    return TextField(
      controller: _controllers[campo.nombre],
      enabled: !deshabilitado,
      minLines: lineas,
      maxLines: lineas == 1 ? 1 : lineas + 2,
      keyboardType: numerico ? TextInputType.number : TextInputType.text,
      inputFormatters:
          numerico ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        labelText: etiqueta,
        errorText: error,
        isDense: true,
      ),
    );
  }

  Widget _selectField(
    CampoDinamico campo,
    String etiqueta,
    String? error,
    bool deshabilitado,
  ) {
    final valor = _valores[campo.nombre];
    return DropdownButtonFormField<String>(
      initialValue: valor,
      decoration: InputDecoration(
        labelText: etiqueta,
        errorText: error,
        isDense: true,
      ),
      items: [
        for (final op in campo.opciones)
          DropdownMenuItem(value: op, child: Text(op)),
      ],
      onChanged: deshabilitado
          ? null
          : (v) => setState(() => _valores[campo.nombre] = v ?? ''),
    );
  }

  Widget _dateField(
    CampoDinamico campo,
    String etiqueta,
    String? error,
    bool deshabilitado,
  ) {
    final valor = _valores[campo.nombre] ?? '';
    return InkWell(
      onTap: deshabilitado
          ? null
          : () async {
              final ahora = DateTime.now();
              final fecha = await showDatePicker(
                context: context,
                initialDate: ahora,
                firstDate: DateTime(ahora.year - 100),
                lastDate: DateTime(ahora.year + 10),
              );
              if (fecha != null) {
                setState(() {
                  _valores[campo.nombre] =
                      '${fecha.year.toString().padLeft(4, '0')}-'
                      '${fecha.month.toString().padLeft(2, '0')}-'
                      '${fecha.day.toString().padLeft(2, '0')}';
                });
              }
            },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          errorText: error,
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(valor.isEmpty ? 'Seleccionar fecha' : valor),
      ),
    );
  }

  /// Campo FILE funcional: elige un archivo (foto/PDF/…) y lo retiene hasta
  /// que el agente pida subirlo (evento `subir_archivos`).
  Widget _fileField(
    CampoDinamico campo,
    String etiqueta,
    String? error,
    bool deshabilitado,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final archivo = _archivos[campo.nombre];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: TextStyle(
            color: error != null
                ? colorScheme.error
                : colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        if (archivo == null)
          OutlinedButton.icon(
            onPressed: deshabilitado ? null : () => _elegirArchivo(campo),
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Adjuntar'),
          )
        else
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
                    archivo.tamanoLegible.isEmpty
                        ? archivo.nombre
                        : '${archivo.nombre} · ${archivo.tamanoLegible}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                IconButton(
                  tooltip: 'Quitar',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: deshabilitado
                      ? null
                      : () => setState(() => _archivos.remove(campo.nombre)),
                ),
              ],
            ),
          ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error,
            style: TextStyle(color: colorScheme.error, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Future<void> _elegirArchivo(CampoDinamico campo) async {
    final exts = _extensionesDe(campo.tiposAceptados);
    final result = await FilePicker.platform.pickFiles(
      type: exts.isEmpty ? FileType.any : FileType.custom,
      allowedExtensions: exts.isEmpty ? null : exts,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.first;
    if (f.path == null) return;

    setState(() {
      _archivos[campo.nombre] = ArchivoParaSubir(
        campoFormulario: campo.nombre,
        path: f.path!,
        nombre: f.name,
        tamanoBytes: f.size,
        extension: (f.extension ?? '').toLowerCase(),
      );
      _erroresLocales[campo.nombre] = null;
    });
  }

  /// Convierte `tiposAceptados` (MIME como "application/pdf" o extensiones como
  /// "pdf") a una lista de extensiones para file_picker. Si hay comodines o algo
  /// desconocido, devuelve vacío → se permite cualquier archivo.
  List<String> _extensionesDe(List<String> tipos) {
    const mimeAExt = {
      'jpeg': 'jpg',
      'jpg': 'jpg',
      'png': 'png',
      'gif': 'gif',
      'webp': 'webp',
      'pdf': 'pdf',
      'mp4': 'mp4',
      'quicktime': 'mov',
      'msword': 'doc',
    };
    final exts = <String>{};
    for (final t in tipos) {
      final lower = t.toLowerCase().trim();
      if (lower.contains('*')) return const [];
      if (lower.contains('/')) {
        final sub = lower.split('/').last;
        final ext = mimeAExt[sub];
        if (ext == null) return const [];
        exts.add(ext);
      } else {
        final limpio = lower.replaceAll('.', '');
        if (RegExp(r'^[a-z0-9]+$').hasMatch(limpio)) exts.add(limpio);
      }
    }
    return exts.toList();
  }
}
