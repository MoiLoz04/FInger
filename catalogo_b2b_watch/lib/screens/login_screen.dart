import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';
import 'home_screen.dart';

/// Pantalla mínima de inicio de sesión para el reloj.
///
/// El reloj necesita su propia sesión activa de Supabase (no comparte
/// la sesión del navegador web) para que las políticas RLS sepan a
/// quién pertenece la cotización que va a leer/actualizar.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await SupabaseService.instance.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      setState(() => _error = 'Credenciales inválidas');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'INDUSTRIA',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF22C55E),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CompactField(
                    controller: _emailController,
                    hint: 'Email',
                  ),
                  const SizedBox(height: 8),
                  _CompactField(
                    controller: _passwordController,
                    hint: 'Password',
                    obscure: true,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: const Color(0xFF14171C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(_loading ? '...' : 'Entrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;

  const _CompactField({
    required this.controller,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF5B6470), fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF1C2128),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
