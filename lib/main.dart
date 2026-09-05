import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Importa Riverpod
import 'core/theme/app_theme.dart';
import 'core/providers/session_provider.dart'; // 2. Importa el provider de sesión
import 'domains/auth/ui/screens/onboarding_screen.dart';
import 'core/ui/app_shell.dart'; // 3. Importa el interior de la app

void main() {
  runApp(const ProviderScope(child: LifeRpgApp()));
}

// 4. Cambiamos de StatelessWidget a ConsumerWidget para escuchar a Riverpod
class LifeRpgApp extends ConsumerWidget {
  const LifeRpgApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 5. Consultamos SQLite al instante de abrir la app
    final sessionState = ref.watch(localUserIdProvider);

    return MaterialApp(
      title: 'Life RPG',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // 6. El "Cadenero": Decide qué pantalla mostrar
      home: sessionState.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, stackTrace) =>
            Scaffold(body: Center(child: Text('Error crítico: $error'))),
        data: (userId) {
          // Si no hay ID, te obliga a hacer el onboarding
          if (userId == null) {
            return const OnboardingScreen();
          }
          // Si ya hay ID, entras directo a tus hábitos
          return const AppShell();
        },
      ),
    );
  }
}
