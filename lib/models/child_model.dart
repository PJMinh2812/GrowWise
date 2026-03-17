class ChildModel {
  final String id;
  final String familyId;
  final String? userId;
  final String name;
  final int age;
  final String avatarEmoji;
  final int level;
  final int totalCoins;
  final int spendJar;
  final int saveJar;
  final int shareJar;
  final int xp;
  final int xpToNextLevel;
  final List<Map<String, dynamic>> badges;

  const ChildModel({
    this.id = '',
    this.familyId = '',
    this.userId,
    required this.name,
    this.age = 8,
    this.avatarEmoji = '👦',
    this.level = 1,
    this.totalCoins = 0,
    this.spendJar = 0,
    this.saveJar = 0,
    this.shareJar = 0,
    this.xp = 0,
    this.xpToNextLevel = 100,
    this.badges = const [],
  });

  factory ChildModel.fromJson(
    Map<String, dynamic> json, {
    List<Map<String, dynamic>>? badges,
  }) {
    return ChildModel(
      id: json['id'] as String,
      familyId: json['family_id'] as String? ?? '',
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      age: json['age'] as int? ?? 8,
      avatarEmoji: json['avatar_emoji'] as String? ?? '👦',
      level: json['level'] as int? ?? 1,
      totalCoins: json['total_coins'] as int? ?? 0,
      spendJar: json['spend_jar'] as int? ?? 0,
      saveJar: json['save_jar'] as int? ?? 0,
      shareJar: json['share_jar'] as int? ?? 0,
      xp: json['xp'] as int? ?? 0,
      xpToNextLevel: json['xp_to_next_level'] as int? ?? 100,
      badges: badges ?? [],
    );
  }

  ChildModel copyWith({
    String? name,
    int? age,
    String? avatarEmoji,
    int? level,
    int? totalCoins,
    int? spendJar,
    int? saveJar,
    int? shareJar,
    int? xp,
    int? xpToNextLevel,
    List<Map<String, dynamic>>? badges,
  }) {
    return ChildModel(
      id: id,
      familyId: familyId,
      userId: userId,
      name: name ?? this.name,
      age: age ?? this.age,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      level: level ?? this.level,
      totalCoins: totalCoins ?? this.totalCoins,
      spendJar: spendJar ?? this.spendJar,
      saveJar: saveJar ?? this.saveJar,
      shareJar: shareJar ?? this.shareJar,
      xp: xp ?? this.xp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      badges: badges ?? this.badges,
    );
  }
}
