import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      bool isAvailable = await _auth.canCheckBiometrics;
      bool isSupported = await _auth.isDeviceSupported();

      if (!isAvailable || !isSupported) {
        // Allow access if no biometric (optional)
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