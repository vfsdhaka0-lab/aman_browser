import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'pin_screen.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const LockScreen({super.key, required this.onSuccess});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  String message = "Unlock with fingerprint";

  Future<void> authenticate() async {
    try {
      final available = await auth.canCheckBiometrics;

      if (!available) {
        openPin();
        return;
      }

      final success = await auth.authenticate(
        localizedReason: "Unlock browser",
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (success) {
        widget.onSuccess();
      } else {
        openPin();
      }
    } catch (_) {
      openPin();
    }
  }

  void openPin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PinScreen(
          onSuccess: widget.onSuccess,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    authenticate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
