import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';
import 'success_screen.dart';

/// Pantalla 3 del flujo del reloj: confirmación final antes de
/// enviar. Un botón verde central grande dispara la actualización en
/// Supabase (marca la cotización como `enviada`, `enviado_desde =
/// 'watch'`, usando el `user_id` de la sesión activa) sin pedir
/// ningún dato de contacto adicional — esos ya quedaron guardados en
/// el perfil desde la web.
class ConfirmScreen extends StatefulWidget {
  final Map<String, dynamic> quote;

  const ConfirmScreen({super.key, required this.quote});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  bool _sending = false;
  String? _error;

  Future<void> _handleSend() async {
    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      final updated = await SupabaseService.instance.submitQuoteFromWatch(
        widget.quote['id'],
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SuccessScreen(referencia: updated['referencia']),
        ),
      );
    } catch (e) {
      setState(() => _error = 'No se pudo enviar. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CONFIRMAR ENVÍO',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF5B6470),
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Folio ${widget.quote['referencia'] ?? '—'}',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFFF7F7F4),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _sending ? null : _handleSend,
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF22C55E),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withOpacity(0.35),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: _sending
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                color: Color(0xFF14171C),
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Color(0xFF14171C),
                              size: 34,
                            ),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
