import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/ui/app_shell.dart';

void main() {
  runApp(const LifeRpgApp());
}

class LifeRpgApp extends StatelessWidget {
  const LifeRpgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life RPG',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Conectamos el gestor de navegación principal
      home: const AppShell(),
    );
  }
}
