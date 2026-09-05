import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_shell.dart';
import '../../../../core/providers/session_provider.dart';

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
  bool _isLoading = false; // Estado local para proteger la transacción SQL

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

  @override
  Widget build(BuildContext context) {
    final draftController = ref.read(authDraftProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomeStep(),

                  ArchetypeSelectorWidget(
                    onSelected: (val) {
                      draftController.setArchetype(val);
                      _nextPage();
                    },
                  ),

                  ChronobiologySelectorWidget(
                    // Ya no recibe 'val', solo avanza la página
                    onSelected: () => _nextPage(),
                  ),

                  VulnerabilitySelectorWidget(
                    onSelected: (val) async {
                      setState(() => _isLoading = true);

                      draftController.setVulnerability(val);
                      final success = await draftController.finalizeContract();

                      if (!context.mounted) return;

                      if (success) {
                        ref.invalidate(localUserIdProvider);

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const AppShell(),
                          ),
                        );
                      } else {
                        setState(() => _isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Error al crear el contrato clínico. Inténtalo de nuevo.',
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),

              // Capa de carga sobrepuesta
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
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
