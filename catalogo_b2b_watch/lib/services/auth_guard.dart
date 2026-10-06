import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../screens/pin_screen.dart';

/// AuthGuard evalúa, en orden de prioridad:
/// 1. Si hay biometría disponible → la usa.
/// 2. Si no, cae al PIN de 4 dígitos almacenado en SecureStorage.
/// 3. Si tampoco existe PIN → redirige a la pantalla de configuración.
class AuthGuard extends StatefulWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    _tryUnlock();
  }

  Future<void> _tryUnlock() async {
    final auth = LocalAuthentication();
    final canBio = await auth.canCheckBiometrics;

    if (canBio) {
      final ok = await auth.authenticate(
        localizedReason: 'Autentícate para acceder a IndustrIA',
        options: const AuthenticationOptions(biometricOnly: false),
      );
      if (ok && mounted) {
        setState(() => _unlocked = true);
        return;
      }
    }

    // Fallback: PIN
    if (!mounted) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PinScreen()),
    );
    if (result == true && mounted) setState(() => _unlocked = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_unlocked) {
      return const Scaffold(
        backgroundColor: Color(0xFF000000),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF22C55E)),
        ),
      );
    }
    return widget.child;
  }
}
