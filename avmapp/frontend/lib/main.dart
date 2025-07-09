import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive başlatma ve kutu açma
  await Hive.initFlutter();
  await Hive.openBox<String>('notesBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AVMNEREDE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Quicksand',
        primaryColor: const Color(0xFF41436A),
        useMaterial3: true,
      ),
      home: OnboardingPage(), // Her açılışta onboarding göster
    );
  }
}
