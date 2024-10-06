import 'package:flutter/material.dart';
import 'package:webdex_app/screens/earth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: Colors.white24,
        ),
      ),
      home: const EarthScreen(),
    );
  }
}
