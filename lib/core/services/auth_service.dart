import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      // 🧪 DEV MODE BYPASS (IMPORTANT)
      if (kDebugMode) {
        return true;
      }

      bool isAvailable = await _auth.canCheckBiometrics;
      bool isSupported = await _auth.isDeviceSupported();

      if (!isAvailable || !isSupported) {
        return true;
      }

      return await _auth.authenticate(
        localizedReason: 'Unlock Browser',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}