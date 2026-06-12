import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Detecta si hay conexión de red y lo expone a la UI.
///
/// Nota: connectivity_plus dice si hay **red** (WiFi/datos), no si el internet
/// realmente funciona. Para "conectado pero server caído" ya está el sync
/// best-effort. Para la app, esto alcanza para el banner y los bloqueos.
class ConectividadProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription _sub;

  bool _online = true; // optimista hasta el primer chequeo
  bool get online => _online;
  bool get offline => !_online;

  /// Se llama cuando se recupera la conexión (offline → online).
  /// app.dart lo usa para disparar el sync.
  void Function()? alReconectar;

  ConectividadProvider() {
    _sub = _connectivity.onConnectivityChanged.listen(_actualizar);
    _chequeoInicial();
  }

  Future<void> _chequeoInicial() async {
    try {
      _actualizar(await _connectivity.checkConnectivity());
    } catch (_) {/* dejamos el valor optimista */}
  }

  void _actualizar(List<ConnectivityResult> resultados) {
    final ahoraOnline =
        resultados.any((r) => r != ConnectivityResult.none);
    final estabaOnline = _online;
    if (ahoraOnline != estabaOnline) {
      _online = ahoraOnline;
      notifyListeners();
      if (!estabaOnline && ahoraOnline) {
        alReconectar?.call();
      }
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
