import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/onboarding_page.dart';

void main() async {
  // 1. Pastikan binding flutter terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Muat file .env untuk mengambil API Key & URL secara rahasia
  await dotenv.load(fileName: ".env");

  // 3. Inisialisasi koneksi Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

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
