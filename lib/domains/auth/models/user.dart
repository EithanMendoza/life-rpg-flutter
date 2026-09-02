class User {
  final String id;
  final String? oauthId;
  final int xp;
  final int goldBalance;
  final String dayStartTime;
  final String accountStatus;

  // Contrato Clínico
  final int shields;
  final bool isSleepModeActive;

  // Nuevas Propiedades: Perfil Psicológico y Rastreo
  final String? archetype;
  final String? primaryVulnerability;
  final String? targetSleepTime;
  final String? createdAt;

  const User({
    required this.id,
    this.oauthId,
    this.xp = 0,
    this.goldBalance = 0,
    this.dayStartTime = '00:00:00',
    this.accountStatus = 'active',
    this.shields = 0,
    this.isSleepModeActive = false,
    this.archetype,
    this.primaryVulnerability,
    this.targetSleepTime,
    this.createdAt,
  });

  User copyWith({
    String? id,
    String? oauthId,
    int? xp,
    int? goldBalance,
    String? dayStartTime,
    String? accountStatus,
    int? shields,
    bool? isSleepModeActive,
    String? archetype,
    String? primaryVulnerability,
    String? targetSleepTime,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      oauthId: oauthId ?? this.oauthId,
      xp: xp ?? this.xp,
      goldBalance: goldBalance ?? this.goldBalance,
      dayStartTime: dayStartTime ?? this.dayStartTime,
      accountStatus: accountStatus ?? this.accountStatus,
      shields: shields ?? this.shields,
      isSleepModeActive: isSleepModeActive ?? this.isSleepModeActive,
      archetype: archetype ?? this.archetype,
      primaryVulnerability: primaryVulnerability ?? this.primaryVulnerability,
      targetSleepTime: targetSleepTime ?? this.targetSleepTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'oauth_id': oauthId,
      'xp': xp,
      'gold_balance': goldBalance,
      'day_start_time': dayStartTime,
      'account_status': accountStatus,
      'shields': shields,
      'is_sleep_mode_active': isSleepModeActive ? 1 : 0,
      'archetype': archetype,
      'primary_vulnerability': primaryVulnerability,
      'target_sleep_time': targetSleepTime,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      oauthId: map['oauth_id'] as String?,
      xp: map['xp'] as int? ?? 0,
      goldBalance: map['gold_balance'] as int? ?? 0,
      dayStartTime: map['day_start_time'] as String? ?? '00:00:00',
      accountStatus: map['account_status'] as String? ?? 'active',
      shields: map['shields'] as int? ?? 0,
      isSleepModeActive: (map['is_sleep_mode_active'] as int? ?? 0) == 1,
      archetype: map['archetype'] as String?,
      primaryVulnerability: map['primary_vulnerability'] as String?,
      targetSleepTime: map['target_sleep_time'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }
}
