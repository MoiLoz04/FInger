import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta visual para mostrar un producto o item de cotización en la
/// pantalla circular del smartwatch.
///
/// Sigue el estándar de diseño Material 3 mediante [Card] y [ListTile],
/// con una imagen circular a la izquierda (o un ícono de respaldo si no
/// hay `imagenUrl`), el nombre del producto, y la cantidad mostrada en
/// tipografía monoespaciada (JetBrains Mono) para reforzar que se trata
/// de un dato técnico/numérico.
///
/// Ejemplo de uso:
/// ```dart
/// WearableCard(
///   nombre: 'Sensor PT100 Industrial',
///   cantidad: 3,
///   imagenUrl: 'https://...',
/// )
/// ```
class WearableCard extends StatelessWidget {
  /// Nombre del producto a mostrar.
  final String nombre;

  /// Cantidad seleccionada de este producto en la cotización.
  final int cantidad;

  /// URL de la imagen del producto. Si es `null` o falla la carga,
  /// se muestra un ícono de respaldo.
  final String? imagenUrl;

  /// Callback opcional al presionar la tarjeta (por ejemplo, para
  /// expandir detalles del producto). Si es `null`, la tarjeta no
  /// responde a toques.
  final VoidCallback? onTap;

  /// Crea una tarjeta de producto para el catálogo/carrito del reloj.
  const WearableCard({
    super.key,
    required this.nombre,
    required this.cantidad,
    this.imagenUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: const Color(0xFF1C2128),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 0,
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: imagenUrl != null && imagenUrl!.isNotEmpty
              ? Image.network(
                  imagenUrl!,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackIcon(),
                )
              : _fallbackIcon(),
        ),
        title: Text(
          nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFF7F7F4),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Text(
          'x$cantidad',
          style: GoogleFonts.jetBrainsMono(
            color: const Color(0xFF22C55E),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      width: 36,
      height: 36,
      color: const Color(0xFF14171C),
      child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF22C55E), size: 18),
    );
  }
}
