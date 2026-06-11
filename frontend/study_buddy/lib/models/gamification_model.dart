class GamificationModel {
  final int xp;
  final int currentStreak;
  final int longestStreak;
  final List<String> badges;
  final int weeklyXp;
  final int? weeklyRank;
  final String? college;

  const GamificationModel({
    required this.xp,
    required this.currentStreak,
    required this.longestStreak,
    required this.badges,
    required this.weeklyXp,
    this.weeklyRank,
    this.college,
  });

  factory GamificationModel.fromJson(Map<String, dynamic> json) {
    return GamificationModel(
      xp: json['xp'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      badges: List<String>.from(json['badges'] ?? const []),
      weeklyXp: json['weeklyXp'] ?? 0,
      weeklyRank: json['weeklyRank'],
      college: json['college'],
    );
  }
}

class LeaderboardEntryModel {
  final String userId;
  final String name;
  final String? avatarUrl;
  final String? college;
  final int weeklyXp;
  final int totalXp;
  final int rank;
  final List<String> badges;

  const LeaderboardEntryModel({
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.college,
    required this.weeklyXp,
    required this.totalXp,
    required this.rank,
    required this.badges,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? 'Student',
      avatarUrl: json['avatarUrl'],
      college: json['college'],
      weeklyXp: json['weeklyXp'] ?? 0,
      totalXp: json['totalXp'] ?? 0,
      rank: json['rank'] ?? 0,
      badges: List<String>.from(json['badges'] ?? const []),
    );
  }
}
