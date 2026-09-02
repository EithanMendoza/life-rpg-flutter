import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../repositories/auth_local_repository.dart';
import '../../tracker/use_cases/prescribe_odysseus_contract_use_case.dart';

class AuthDraftState {
  final String? selectedArchetype;
  final String? targetSleepTime;
  final String? selectedVulnerability;

  const AuthDraftState({
    this.selectedArchetype,
    this.targetSleepTime,
    this.selectedVulnerability,
  });

  AuthDraftState copyWith({
    String? selectedArchetype,
    String? targetSleepTime,
    String? selectedVulnerability,
  }) {
    return AuthDraftState(
      selectedArchetype: selectedArchetype ?? this.selectedArchetype,
      targetSleepTime: targetSleepTime ?? this.targetSleepTime,
      selectedVulnerability:
          selectedVulnerability ?? this.selectedVulnerability,
    );
  }
}

class AuthDraftController extends Notifier<AuthDraftState> {
  @override
  AuthDraftState build() {
    return const AuthDraftState();
  }

  void setArchetype(String archetype) {
    state = state.copyWith(selectedArchetype: archetype);
  }

  void setSleepTime(String time) {
    state = state.copyWith(targetSleepTime: time);
  }

  void setVulnerability(String vulnerability) {
    state = state.copyWith(selectedVulnerability: vulnerability);
  }

  /// Orquestador Final del Contrato de Odiseo
  Future<bool> finalizeContract() async {
    if (state.selectedArchetype == null ||
        state.targetSleepTime == null ||
        state.selectedVulnerability == null) {
      return false; // Evita inyecciones incompletas
    }

    try {
      const uuid = Uuid();
      final shadowAccountId = uuid.v4();
      final nowUtc = DateTime.now().toUtc().toIso8601String();

      // Paso A: Crear entidad del usuario
      final newUser = User(
        id: shadowAccountId,
        dayStartTime: '00:00:00', // Offset por defecto
        targetSleepTime: state.targetSleepTime!,
        archetype: state.selectedArchetype!,
        primaryVulnerability: state.selectedVulnerability!,
        createdAt: nowUtc,
      );

      // Paso B: Invocar el Use Case de Diagnóstico
      final useCase = PrescribeOdysseusContractUseCase();
      final contract = useCase.execute(
        userId: shadowAccountId,
        archetype: state.selectedArchetype!,
        vulnerability: state.selectedVulnerability!,
        targetSleepTime: state.targetSleepTime!,
      );

      // Paso C: Ejecutar la Transacción SQL
      final repository = AuthLocalRepository();
      await repository.createShadowAccountWithContract(newUser, contract);

      // Limpieza de memoria
      state = const AuthDraftState();

      return true;
    } catch (e) {
      // Capturar y reportar el error (Crashlytics)
      return false;
    }
  }
}

final authDraftProvider = NotifierProvider<AuthDraftController, AuthDraftState>(
  () {
    return AuthDraftController();
  },
);
