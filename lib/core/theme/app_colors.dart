import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Colores base de la interfaz (Modo Oscuro)
  static const Color background = Color(0xFF121212); // Fondo oscuro profundo
  static const Color surface = Color(
    0xFF1E1E1E,
  ); // Elevación para tarjetas y menús

  // Colores de acento e interacción
  static const Color primary = Color(
    0xFF4CAF50,
  ); // Acento de éxito / Dopamina (Verde)

  // Colores de estado (Gamificación y penalizaciones)
  static const Color error = Color(
    0xFFCF6679,
  ); // Castigos, daño o errores (Rojo suave)
  static const Color warning = Color(
    0xFFFFB74D,
  ); // Alertas o estado de bancarrota (Naranja)

  // Tipografía
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
}
