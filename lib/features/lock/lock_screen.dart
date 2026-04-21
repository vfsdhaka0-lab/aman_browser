import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../browser/browser_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String message = "Unlock your browser";

  @override
  void initState() {
    super.initState();
    _tryUnlock();
  }

  Future<void> _tryUnlock() async {
    setState(() {
      isLoading = true;
      message = "Authenticating...";
    });

    bool success = await _authService.authenticate();

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BrowserScreen()),
      );
    } else {
      setState(() {
        isLoading = false;
        message = "Authentication failed. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            const Icon(Icons.lock, size: 80),

            const SizedBox(height: 20),

            Text(
              message,
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _tryUnlock,
                    child: const Text("Unlock"),
                  ),
          ],
        ),
      ),
    );
  }
}