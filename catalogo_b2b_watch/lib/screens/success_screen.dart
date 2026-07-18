import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

/// Pantalla 4 del flujo del reloj: confirmación visual de que la
/// cotización se envió correctamente. Muestra una animación de
/// checkmark y el folio `COT-XXXXX` generado por el trigger de
/// Supabase, y después de unos segundos regresa solo a Inicio.
class SuccessScreen extends StatefulWidget {
  final String referencia;

  const SuccessScreen({super.key, required this.referencia});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF22C55E),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF14171C),
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Cotización enviada',
                style: GoogleFonts.inter(
                  color: const Color(0xFFF7F7F4),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.referencia,
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF22C55E),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
