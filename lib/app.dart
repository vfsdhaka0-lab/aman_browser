import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/browser/browser_screen.dart';
import 'features/browser/tab_provider.dart';
import 'features/auth/auth_manager.dart';
import 'features/auth/lock_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 🔒 AUTO LOCK WHEN APP GOES BACKGROUND
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final auth = context.read<AuthManager>();

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      auth.lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TabProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthManager(),
        ),
      ],
      child: Consumer<AuthManager>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorSchemeSeed: Colors.blue,
            ),

            home: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: auth.isUnlocked
                  ? const BrowserScreen(
                      key: ValueKey("browser"),
                    )
                  : LockScreen(
                      key: const ValueKey("lock"),
                      onSuccess: () {
                        auth.unlock();
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
} u
