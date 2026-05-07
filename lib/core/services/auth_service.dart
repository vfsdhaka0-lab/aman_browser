import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      // ✅ Check support
      bool isSupported = await _auth.isDeviceSupported();
      bool canCheck = await _auth.canCheckBiometrics();

      if (!isSupported || !canCheck) {
        debugPrint("Biometric not supported");
        return false;
      }

      // ✅ Get available biometrics
      List<BiometricType> biometrics =
          await _auth.getAvailableBiometrics();

      debugPrint("Available biometrics: $biometrics");

      if (biometrics.isEmpty) {
        return false;
      }

      // ✅ Authentication
      bool authenticated = await _auth.authenticate(
        localizedReason: 'Unlock Aman Browser',
        options: const AuthenticationOptions(
          biometricOnly: false, // 🔥 IMPORTANT FIX
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      return authenticated;
    } catch (e) {
      debugPrint("AUTH ERROR: $e");
      return false;
    }
  }
}