import 'package:tramites_app/models/tramite.dart';

/// Buscador offline de trámites por coincidencia de palabras.
///
/// Función pura: recibe el texto del usuario + los trámites (cacheados) y
/// devuelve los que mejor coinciden. No sabe de conexión ni de UI.
class BuscadorTramites {
  /// Palabras "vacías" que no aportan al matcheo (se ignoran).
  static const _stopwords = {
    'necesito', 'necesitaria', 'necesitaría', 'quiero', 'quisiera', 'queria',
    'quería', 'hacer', 'para', 'por', 'una', 'uno', 'un', 'unos', 'unas',
    'el', 'la', 'los', 'las', 'de', 'del', 'que', 'mi', 'mis', 'con', 'sobre',
    'como', 'este', 'esta', 'esto', 'esa', 'ese', 'tengo', 'me', 'se', 'su',
    'sus', 'hola', 'buenas', 'dia', 'dias', 'ayuda', 'favor', 'porfavor',
  };

  /// Devuelve los trámites que mejor coinciden con [texto], de mayor a menor.
  /// Lista vacía = no hubo coincidencia (la UI ofrece "Ver todos").
  static List<TramiteDisponible> buscar(
    String texto,
    List<TramiteDisponible> tramites, {
    int max = 3,
  }) {
    final consulta = _tokens(texto);
    if (consulta.isEmpty) return const [];

    final puntuados = <_Puntuado>[];
    for (final t in tramites) {
      if (!t.activo) continue;
      final campos = _tokens(
        '${t.nombre} ${t.descripcion ?? ''} '
        '${t.etiquetas.join(' ')} ${t.requisitos.join(' ')}',
      );
      var score = 0;
      for (final q in consulta) {
        for (final c in campos) {
          if (c == q) {
            score += 2; // coincidencia exacta
            break;
          }
          if (q.length >= 4 && (c.contains(q) || q.contains(c))) {
            score += 1; // parcial (tolera plurales / typos leves)
            break;
          }
        }
      }
      if (score > 0) puntuados.add(_Puntuado(t, score));
    }

    puntuados.sort((a, b) => b.score.compareTo(a.score));
    return puntuados.take(max).map((p) => p.tramite).toList();
  }

  static List<String> _tokens(String s) {
    return _normalizar(s)
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.length > 2 && !_stopwords.contains(w))
        .toList();
  }

  static String _normalizar(String s) {
    const acentos = {
      'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n',
    };
    final sb = StringBuffer();
    for (final ch in s.toLowerCase().split('')) {
      sb.write(acentos[ch] ?? ch);
    }
    return sb.toString();
  }
}

class _Puntuado {
  final TramiteDisponible tramite;
  final int score;
  const _Puntuado(this.tramite, this.score);
}
