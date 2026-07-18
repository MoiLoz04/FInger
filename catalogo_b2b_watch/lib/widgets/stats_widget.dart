import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget compacto de indicadores de desempeño para mostrar en el
/// reloj: total de tareas/items, cuántos están en progreso (borrador)
/// y cuántos ya se completaron (enviados).
///
/// Pensado para pantallas circulares pequeñas: usa una fila de tres
/// columnas iguales, números grandes en JetBrains Mono (igual que el
/// resto de la identidad visual del reloj) y etiquetas cortas debajo.
///
/// Ejemplo de uso:
/// ```dart
/// StatsWidget(
///   totalTareas: 12,
///   enProgreso: 1,
///   completadas: 11,
/// )
/// ```
class StatsWidget extends StatelessWidget {
  /// Número total de cotizaciones registradas para el usuario.
  final int totalTareas;

  /// Número de cotizaciones en estado `borrador`.
  final int enProgreso;

  /// Número de cotizaciones en estado `enviada`.
  final int completadas;

  /// Crea el panel de estadísticas del reloj.
  const StatsWidget({
    super.key,
    required this.totalTareas,
    required this.enProgreso,
    required this.completadas,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatColumn(
          value: totalTareas,
          label: 'TOTAL',
          color: const Color(0xFFF7F7F4),
        ),
        _StatColumn(
          value: enProgreso,
          label: 'EN CURSO',
          color: const Color(0xFFF59E0B),
        ),
        _StatColumn(
          value: completadas,
          label: 'ENVIADAS',
          color: const Color(0xFF22C55E),
        ),
      ],
    );
  }
}

/// Columna individual de una métrica dentro de [StatsWidget].
/// Widget privado: solo se usa para componer la fila de estadísticas.
class _StatColumn extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: GoogleFonts.jetBrainsMono(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            color: const Color(0xFF5B6470),
            fontSize: 8,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
