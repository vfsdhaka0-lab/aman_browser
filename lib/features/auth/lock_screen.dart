import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const LockScreen({super.key, required this.onSuccess});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  String message = "Authenticate to continue";

  Future<void> authenticate() async {
    try {
      final isAvailable = await auth.canCheckBiometrics;

      if (!isAvailable) {
        setState(() {
          message = "Biometric not available";
        });
        return;
      }

      final success = await auth.authenticate(
        localizedReason: "Unlock your browser",
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (success) {
        widget.onSuccess();
      } else {
        setState(() {
          message = "Authentication failed";
        });
      }
    } catch (e) {
      setState(() {
        message = "Error: $e";
      });
    }
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text(message, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: authenticate,
              child: const Text("Try Again"),
            )
          ],
        ),
      ),
    );
  }
}
