import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'supabase_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _kPinHash = 'pin_hash';
  static const _kSalt = 'pin_salt';
  static const _kFailedAttempts = 'failed_attempts';
  static const _kLockoutUntil = 'lockout_until';

  static const int maxAttempts = 3;
  static const Duration lockoutDuration = Duration(seconds: 30);

  final _storage = kIsWeb 
      ? const FlutterSecureStorage() 
      : const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
      
  final _localAuth = kIsWeb ? null : LocalAuthentication();

  bool _unlockedThisSession = false;
  bool get isUnlocked => _unlockedThisSession;

  // Verifica si el usuario ya configuró un PIN
  Future<bool> hasPin() async {
    return await _storage.read(key: _kPinHash) != null;
  }

  String _generateSalt() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    await _storage.write(key: _kSalt, value: salt);
    await _storage.write(key: _kPinHash, value: hash);
  }

  Future<bool> isLockedOut() async {
    final rawUntil = await _storage.read(key: _kLockoutUntil);
    if (rawUntil == null) return false;
    final until = DateTime.tryParse(rawUntil);
    if (until == null) return false;
    
    if (DateTime.now().isAfter(until)) {
      await _storage.delete(key: _kFailedAttempts);
      await _storage.delete(key: _kLockoutUntil);
      return false;
    }
    return true;
  }

  Future<Duration> remainingLockout() async {
    final rawUntil = await _storage.read(key: _kLockoutUntil);
    if (rawUntil == null) return Duration.zero;
    final until = DateTime.tryParse(rawUntil);
    if (until == null) return Duration.zero;
    
    final diff = until.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  Future<int> failedAttempts() async {
    final raw = await _storage.read(key: _kFailedAttempts);
    return int.tryParse(raw ?? '0') ?? 0;
  }

  Future<bool> validatePin(String pin) async {
    if (await isLockedOut()) return false;

    final salt = await _storage.read(key: _kSalt);
    final storedHash = await _storage.read(key: _kPinHash);
    
    // Si no hay PIN, no podemos validar
    if (salt == null || storedHash == null) return false;

    if (_hashPin(pin, salt) == storedHash) {
      await _storage.delete(key: _kFailedAttempts);
      await _storage.delete(key: _kLockoutUntil);
      _unlockedThisSession = true;
      return true;
    }

    final currentRaw = await _storage.read(key: _kFailedAttempts);
    final current = int.tryParse(currentRaw ?? '0') ?? 0;
    final updated = current + 1;
    await _storage.write(key: _kFailedAttempts, value: updated.toString());

    if (updated >= maxAttempts) {
      final until = DateTime.now().add(lockoutDuration);
      await _storage.write(key: _kLockoutUntil, value: until.toIso8601String());
    }
    return false;
  }

  Future<bool> isBiometricAvailable() async {
    if (kIsWeb || _localAuth == null) return false;
    try {
      return await _localAuth!.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    if (kIsWeb || _localAuth == null) return false;
    try {
      final ok = await _localAuth!.authenticate(
        localizedReason: 'Autentícate para continuar',
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
      if (ok) _unlockedThisSession = true;
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    _unlockedThisSession = false;
    await _storage.deleteAll();
    await SupabaseService.instance.signOut();
  }
}