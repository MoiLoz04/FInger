import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class PinLoginScreen extends StatefulWidget {
  final VoidCallback? onUnlocked;
  const PinLoginScreen({super.key, this.onUnlocked});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String _pin = '';
  String? _error;
  bool _lockedOut = false;
  Duration _remaining = Duration.zero;
  Timer? _lockoutTimer;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    // Forzamos el PIN para pruebas. Quita esta línea si ya tienes un flujo de registro.
    AuthService.instance.setPin('1234');
    _checkLockout();
    _checkBiometric();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkBiometric() async {
    final available = await AuthService.instance.isBiometricAvailable();
    if (mounted) setState(() => _biometricAvailable = available);
  }

  Future<void> _checkLockout() async {
    final locked = await AuthService.instance.isLockedOut();
    if (!locked) {
      if (mounted) setState(() => _lockedOut = false);
      return;
    }
    final remaining = await AuthService.instance.remainingLockout();
    if (mounted) {
      setState(() {
        _lockedOut = true;
        _remaining = remaining;
      });
    }
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      final r = await AuthService.instance.remainingLockout();
      if (r <= Duration.zero) {
        t.cancel();
        if (mounted) setState(() => _lockedOut = false);
      } else {
        if (mounted) setState(() => _remaining = r);
      }
    });
  }

  Future<void> _onDigit(String d) async {
    if (_lockedOut || _pin.length >= 4) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length == 4) await _submit();
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    // Depuración: Mira en la consola de Chrome (F12) qué está llegando
    print("Intentando validar PIN ingresado: $_pin");

    final ok = await AuthService.instance.validatePin(_pin);

    print("Resultado de la validación: $ok");

    if (ok) {
      widget.onUnlocked?.call();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
      return;
    }

    final attempts = await AuthService.instance.failedAttempts();
    final locked = await AuthService.instance.isLockedOut();

    if (mounted) {
      setState(() {
        _pin = '';
        _error = locked
            ? 'Bloqueado por intentos fallidos'
            : 'PIN incorrecto (Intento $attempts/${AuthService.maxAttempts})';
      });
    }
    if (locked) _checkLockout();
  }

  Future<void> _useBiometrics() async {
    final ok = await AuthService.instance.authenticateWithBiometrics();
    if (ok) {
      widget.onUnlocked?.call();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
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
              Text(
                _lockedOut
                    ? 'Bloqueado ${_remaining.inSeconds}s'
                    : 'Ingresa tu PIN',
                style: GoogleFonts.jetBrainsMono(
                  color: _lockedOut
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF5B6470),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(4, (i) {
                  final filled = i < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF1C2128),
                    ),
                  );
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: const TextStyle(
                        color: Color(0xFFF59E0B), fontSize: 10)),
              ],
              const SizedBox(height: 14),
              _buildKeypad(),
              if (_biometricAvailable) ...[
                const SizedBox(height: 10),
                IconButton(
                  onPressed: _lockedOut ? null : _useBiometrics,
                  icon: const Icon(Icons.fingerprint,
                      color: Color(0xFF22C55E), size: 26),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return SizedBox(
      width: 160,
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: keys.map((k) {
          if (k.isEmpty) return const SizedBox.shrink();
          return GestureDetector(
            onTap: _lockedOut
                ? null
                : () => k == '⌫' ? _onBackspace() : _onDigit(k),
            child: Center(
              child: Text(
                k,
                style: GoogleFonts.jetBrainsMono(
                  color: _lockedOut ? Colors.white24 : Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
