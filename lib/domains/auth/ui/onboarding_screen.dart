import 'package:flutter/material.dart';
// Importamos nuestro sistema de diseño centralizado
import '../../../../core/theme/app_colors.dart';
// Importamos el shell temporalmente para poder probar la navegación
import '../../../../core/ui/app_shell.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Placeholder para Ilustración de Hero / Logo de Life RPG
              Container(
                height: 200,
                width: 200,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 48),

              const Text(
                'Bienvenido a Life RPG',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              const Text(
                'Forja tu disciplina. Sube de nivel en la vida real. \nFricción cero, recompensas inmediatas.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5, // Mejoramos la legibilidad del texto multilínea
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Botón de Acción Principal (CTA)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Fase 2 - Crear Shadow Account (UUID) e inyectar en sqflite

                    // Acción de prueba visual: Navegamos al Tracker reemplazando la ruta
                    // para que el usuario no pueda volver atrás haciendo "pop".
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const AppShell()),
                    );
                  },
                  child: const Text(
                    'Comenzar Aventura',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
