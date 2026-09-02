import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Importa Riverpod
import 'core/theme/app_theme.dart';
import 'domains/auth/ui/screens/onboarding_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      // 2. Envuelve la aplicación aquí
      child: LifeRpgApp(),
    ),
  );
}

class LifeRpgApp extends StatelessWidget {
  const LifeRpgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life RPG',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const OnboardingScreen(),
    );
  }
}
