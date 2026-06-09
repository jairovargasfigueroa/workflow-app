import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tramites_app/models/contenido_interactivo.dart';
import 'package:tramites_app/models/mensaje_chat.dart';

/// Renderiza un formulario completo a partir de los campos que mandó el agente
/// (evento `pedir_campos_multiples`) y, al confirmar, entrega los datos.
///
/// [onEnviar] recibe (datos, archivosListos). En Fase 2 los campos FILE se
/// muestran pero la selección/subida real es Fase 4, así que no se exigen.
class FormularioDinamico extends StatefulWidget {
  final MensajeChat mensaje;
  final void Function(
    Map<String, String> datos,
    List<Map<String, dynamic>> archivosListos,
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
    var hayError = false;

    for (final campo in widget.mensaje.campos) {
      // Los FILE se manejan en Fase 4: no se exigen ni se incluyen todavía.
      if (campo.tipo == TipoCampoDinamico.file) continue;

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

    // Fase 2: sin archivos (Fase 4 los agrega).
    widget.onEnviar(datos, const []);
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
        return _fileFieldPlaceholder(campo, etiqueta);
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
        border: const OutlineInputBorder(),
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
        border: const OutlineInputBorder(),
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
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(valor.isEmpty ? 'Seleccionar fecha' : valor),
      ),
    );
  }

  /// Campo FILE: visible pero pendiente (la selección/subida es Fase 4).
  Widget _fileFieldPlaceholder(CampoDinamico campo, String etiqueta) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.photo_camera_outlined, size: 18),
              label: const Text('Cámara'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.attach_file, size: 18),
              label: const Text('Archivo'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'La subida de archivos se habilita en la Fase 4.',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
