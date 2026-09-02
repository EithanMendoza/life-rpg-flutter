/// Catálogos en duro (Fat Client) que definen el sistema de vida inicial.
/// Cumple con el Principio Arquitectónico 8 (Plantillas Clínicas Locales).
class ClinicalTemplates {
  // 1. Hábitos Clave por Arquetipo (Fase 1: El Arranque)
  static const Map<String, List<Map<String, dynamic>>> archetypeHabits = {
    'guerrero': [
      {
        'title': 'Rutina de Calistenia (Fase 1)',
        'triggerType': 'event',
        'anchor': 'Levantarme',
      },
      {
        'title': 'Beber 500ml de agua',
        'triggerType': 'event',
        'anchor': 'Terminar calistenia',
      },
    ],
    'erudito': [
      {
        'title': 'Lectura Profunda (15 min)',
        'triggerType': 'event',
        'anchor': 'Preparar café',
      },
      {
        'title': 'Práctica de Shadowing (Idiomas)',
        'triggerType': 'event',
        'anchor': 'Terminar lectura',
      },
    ],
    'alquimista': [
      {
        'title': 'Sesión de Código / Creación',
        'triggerType': 'event',
        'anchor': 'Encender computadora',
      },
      {
        'title': 'Revisión de Backlog',
        'triggerType': 'event',
        'anchor': 'Terminar sesión de código',
      },
    ],
  };

  // 2. Misiones Defensivas por Vulnerabilidad (Fase 3: Trinchera del Agotamiento)
  static const Map<String, List<Map<String, String>>> vulnerabilityMissions = {
    'redes_sociales': [
      {
        'trigger': 'Siento el impulso de abrir TikTok/Instagram',
        'response':
            'Dejaré el celular a 2 metros de distancia y respiraré 3 veces.',
      },
    ],
    'comida_chatarra': [
      {
        'trigger': 'Quiero pedir o comer comida chatarra',
        'response': 'Beberé un vaso entero de agua mineral primero.',
      },
    ],
    'procrastinacion': [
      {
        'trigger': 'Quiero posponer mi bloque de trabajo',
        'response':
            'Abriré la tarea y la miraré por solo 2 minutos sin obligación de empezar.',
      },
    ],
  };
}
