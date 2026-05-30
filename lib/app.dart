import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/browser/tab_provider.dart';
import 'features/browser/browser_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TabProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const BrowserScreen(),
      ),
    );
  }
}
