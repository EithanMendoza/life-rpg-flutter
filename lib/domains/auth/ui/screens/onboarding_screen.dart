import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_shell.dart';

// Importamos los widgets visuales puros y el controlador
import '../widgets/archetype_selector_widget.dart';
import '../widgets/chronobiology_selector_widget.dart';
import '../widgets/vulnerability_selector_widget.dart';
import '../../providers/auth_draft_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _finishOnboarding() {
    // TODO: Fase 2 - Invocar caso de uso de inserción masiva en SQLite
    // Aquí el estado ya tiene los 3 valores completos en ref.read(authDraftProvider)

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draftController = ref.read(authDraftProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: PageView(
            controller: _pageController,
            physics:
                const NeverScrollableScrollPhysics(), // Evita que el usuario deslice sin responder
            children: [
              // PASO 1: Bienvenida Original
              _buildWelcomeStep(),

              // PASO 2: Identidad
              ArchetypeSelectorWidget(
                onSelected: (val) {
                  draftController.setArchetype(val);
                  _nextPage();
                },
              ),

              // PASO 3: Cronobiología
              ChronobiologySelectorWidget(
                onSelected: (val) {
                  draftController.setSleepTime(val);
                  _nextPage();
                },
              ),

              // PASO 4: Vulnerabilidad y Cierre
              VulnerabilitySelectorWidget(
                onSelected: (val) async {
                  draftController.setVulnerability(val);

                  // Invocamos la orquestación atómica
                  final success = await draftController.finalizeContract();

                  if (success && context.mounted) {
                    // Redirección al núcleo de la app.
                    // TrackerScreen ocultará los cronómetros evaluando la antigüedad de la cuenta.
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const AppShell()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        Container(
          height: 200,
          width: 200,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.shield, size: 80, color: AppColors.primary),
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
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
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
            onPressed: _nextPage,
            child: const Text(
              'Comenzar Diagnóstico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
