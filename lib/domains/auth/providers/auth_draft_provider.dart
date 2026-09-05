import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../repositories/auth_local_repository.dart';
import '../../tracker/use_cases/prescribe_odysseus_contract_use_case.dart';

// 1. INYECCIÓN DE DEPENDENCIAS
final authLocalRepositoryProvider = Provider<AuthLocalRepository>((ref) {
  return AuthLocalRepository();
});

final prescribeContractUseCaseProvider =
    Provider<PrescribeOdysseusContractUseCase>((ref) {
      return PrescribeOdysseusContractUseCase();
    });

// 2. ESTADO INMUTABLE (Ahora con TimeOfDay para cálculos precisos)
class AuthDraftState {
  final String? selectedArchetype;
  final TimeOfDay? dayStartTime;
  final TimeOfDay? targetSleepTime;
  final String? selectedVulnerability;

  const AuthDraftState({
    this.selectedArchetype,
    this.dayStartTime,
    this.targetSleepTime,
    this.selectedVulnerability,
  });

  AuthDraftState copyWith({
    String? selectedArchetype,
    TimeOfDay? dayStartTime,
    TimeOfDay? targetSleepTime,
    String? selectedVulnerability,
  }) {
    return AuthDraftState(
      selectedArchetype: selectedArchetype ?? this.selectedArchetype,
      dayStartTime: dayStartTime ?? this.dayStartTime,
      targetSleepTime: targetSleepTime ?? this.targetSleepTime,
      selectedVulnerability:
          selectedVulnerability ?? this.selectedVulnerability,
    );
  }
}

// 3. CONTROLADOR Y LÓGICA DE NEGOCIO
class AuthDraftController extends Notifier<AuthDraftState> {
  @override
  AuthDraftState build() {
    return const AuthDraftState();
  }

  void setArchetype(String archetype) {
    state = state.copyWith(selectedArchetype: archetype);
  }

  void setDayStartTime(TimeOfDay time) {
    state = state.copyWith(dayStartTime: time);
  }

  void setTargetSleepTime(TimeOfDay time) {
    state = state.copyWith(targetSleepTime: time);
  }

  void setVulnerability(String vulnerability) {
    state = state.copyWith(selectedVulnerability: vulnerability);
  }

  // --- MOTOR PSICOLÓGICO: Cálculo de Privación de Sueño ---
  bool isSleepDeprived() {
    if (state.dayStartTime == null || state.targetSleepTime == null)
      return false;

    // Calculamos la diferencia en minutos cruzando la medianoche
    int sleepMinutes =
        (state.dayStartTime!.hour * 60 + state.dayStartTime!.minute) -
        (state.targetSleepTime!.hour * 60 + state.targetSleepTime!.minute);

    if (sleepMinutes <= 0) {
      sleepMinutes +=
          24 *
          60; // Ajuste si cruza la medianoche (ej. duerme 23:00, despierta 06:00)
    }

    return sleepMinutes < (6 * 60); // Menos de 6 horas (360 minutos)
  }

  // Helper para convertir TimeOfDay a String SQL (HH:MM:SS)
  String _formatTimeOfDay(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Future<bool> finalizeContract() async {
    if (state.selectedArchetype == null ||
        state.dayStartTime == null ||
        state.targetSleepTime == null ||
        state.selectedVulnerability == null) {
      return false;
    }

    try {
      const uuid = Uuid();
      final shadowAccountId = uuid.v4();
      final nowUtc = DateTime.now().toUtc().toIso8601String();

      final newUser = User(
        id: shadowAccountId,
        dayStartTime: _formatTimeOfDay(state.dayStartTime!),
        targetSleepTime: _formatTimeOfDay(state.targetSleepTime!),
        archetype: state.selectedArchetype!,
        primaryVulnerability: state.selectedVulnerability!,
        createdAt: nowUtc,
      );

      final useCase = ref.read(prescribeContractUseCaseProvider);
      final repository = ref.read(authLocalRepositoryProvider);

      final contract = useCase.execute(
        userId: shadowAccountId,
        archetype: state.selectedArchetype!,
        vulnerability: state.selectedVulnerability!,
        targetSleepTime: _formatTimeOfDay(state.targetSleepTime!),
      );

      await repository.createShadowAccountWithContract(newUser, contract);

      state = const AuthDraftState();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final authDraftProvider = NotifierProvider<AuthDraftController, AuthDraftState>(
  () => AuthDraftController(),
);
