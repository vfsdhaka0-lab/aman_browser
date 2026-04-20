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

  void _unlock() async {
    bool success = await _authService.authenticate();

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BrowserScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _unlock();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("🔒 Unlocking...")),
    );
  }
}