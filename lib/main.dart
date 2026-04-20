import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/browser/browser_provider.dart';
import 'features/lock/lock_screen.dart';

void main() {
  runApp(const AmanBrowser());
}

class AmanBrowser extends StatelessWidget {
  const AmanBrowser({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BrowserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LockScreen(),
      ),
    );
  }
}