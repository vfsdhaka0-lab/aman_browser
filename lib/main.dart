import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/browser/browser_provider.dart';
import 'features/browser/tab_provider.dart';
import 'features/lock/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AmanBrowser());
}

class AmanBrowser extends StatelessWidget {
  const AmanBrowser({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🌐 Single browser state (optional but useful)
        ChangeNotifierProvider(
          create: (_) => BrowserProvider(),
        ),

        // 🧠 Multi-tab system (MAIN ENGINE)
        ChangeNotifierProvider(
          create: (_) => TabProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Aman Browser',

        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),

        // 🔐 Start with lock screen
        home: const LockScreen(),
      ),
    );
  }
}