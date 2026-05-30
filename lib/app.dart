import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/browser/tab_provider.dart';
import 'features/browser/browser_screen.dart';
import 'features/auth/lock_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool unlocked = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TabProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: unlocked
            ? const BrowserScreen()
            : LockScreen(
                onSuccess: () {
                  setState(() {
                    unlocked = true;
                  });
                },
              ),
      ),
    );
  }
}
