// Un archivo elegido localmente que está a la espera de subirse cuando la
// solicitud ya tenga su solicitudId. El archivo vive en disco (path), no en RAM.

class ArchivoParaSubir {
  /// Documento del kit al que corresponde (campoFormulario = nombre del doc).
  final String campoFormulario;

  /// Ruta del archivo en disco (temporal del selector).
  final String path;

  final String nombre;
  final int tamanoBytes;

  /// Extensión en minúsculas, ej: "pdf".
  final String extension;

  const ArchivoParaSubir({
    required this.campoFormulario,
    required this.path,
    required this.nombre,
    required this.tamanoBytes,
    required this.extension,
  });

  String get tamanoLegible {
    if (tamanoBytes <= 0) return '';
    const unidades = ['B', 'KB', 'MB', 'GB'];
    var valor = tamanoBytes.toDouble();
    var i = 0;
    while (valor >= 1024 && i < unidades.length - 1) {
      valor /= 1024;
      i++;
    }
    final txt = i == 0 ? valor.toStringAsFixed(0) : valor.toStringAsFixed(1);
    return '$txt ${unidades[i]}';
  }
}
