import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final availableBiometrics = await _auth.getAvailableBiometrics();

      if (!isSupported || !canCheck || availableBiometrics.isEmpty) {
        print("❌ Biometrics not available");
        return false;
      }

      print("✅ Biometrics available: $availableBiometrics");

      final result = await _auth.authenticate(
        localizedReason: 'Unlock Browser',
        options: const AuthenticationOptions(
          biometricOnly: true, // 🔥 force fingerprint only
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      print("RESULT: $result");

      return result;
    } catch (e) {
      print("AUTH ERROR: $e");
      return false;
    }
  }
}