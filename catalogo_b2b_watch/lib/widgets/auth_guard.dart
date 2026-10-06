import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../screens/pin_login_screen.dart';

/// Envuelve cualquier pantalla que requiera sesión activa (Supabase)
/// + PIN/biometría desbloqueados en esta ejecución de la app.
class AuthGuard extends StatelessWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final hasSupabaseSession = SupabaseService.instance.isLoggedIn;
    final isUnlocked = AuthService.instance.isUnlocked;

    if (!hasSupabaseSession) {
      // No hay token de Supabase: la lógica de login por email/password
      // existente (LoginScreen) ya maneja esto en main.dart.
      return const Scaffold(
        backgroundColor: Color(0xFF000000),
        body: Center(
          child: Text(
            'Sesión no iniciada',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      );
    }

    if (!isUnlocked) {
      return const PinLoginScreen();
    }

    return child;
  }
}