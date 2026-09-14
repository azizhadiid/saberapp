import 'package:flutter/material.dart';
import 'pages/onboarding_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saber Karbon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B981)),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const OnboardingPage(),
    );
  }
}
