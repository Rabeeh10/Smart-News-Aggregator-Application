import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const SmartNewsApp());
}

class SmartNewsApp extends StatelessWidget {
  const SmartNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart News Aggregator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
