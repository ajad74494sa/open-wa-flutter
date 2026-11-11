import 'package:flutter/material.dart';

import 'src/ui/open_wa_home_screen.dart';

export 'src/ui/open_wa_home_screen.dart' show OpenWaHomeScreen;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OpenWaApp());
}

class OpenWaApp extends StatelessWidget {
  const OpenWaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF128C7E);
    return MaterialApp(
      title: 'OpenWA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandColor,
          brightness: Brightness.dark,
        ),
      ),
      home: const OpenWaHomeScreen(),
    );
  }
}
