import 'package:flutter/material.dart';
import 'package:tramites_app/models/tramite.dart';

class StatusBadge extends StatelessWidget {
  final EstadoSolicitud estado;

  const StatusBadge({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: estado.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
