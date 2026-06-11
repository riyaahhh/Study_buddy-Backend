class UserModel {
  final String id;
  final String name;
  final String email;
  final String? bio;
  final List<String>? subjects;
  final double? latitude;
  final double? longitude;
  final String? avatarUrl;
  final double? reliabilityScore;
  final int? totalJoined;
  final int? totalCompleted;
  final int? xp;
  final int? currentStreak;
  final int? longestStreak;

  // ← ADD THESE
  final String? year;
  final String? college;
  final String? studyMode;
  final String? examTarget;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.subjects,
    this.latitude,
    this.longitude,
    this.avatarUrl,
    this.reliabilityScore,
    this.totalJoined,
    this.totalCompleted,
    this.xp,
    this.currentStreak,
    this.longestStreak,
    // ← ADD THESE
    this.year,
    this.college,
    this.studyMode,
    this.examTarget,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'],
      subjects:
          json['subjects'] != null ? List<String>.from(json['subjects']) : null,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      avatarUrl: json['avatarUrl'],
      reliabilityScore: json['reliabilityScore']?.toDouble(),
      totalJoined: json['totalJoined'],
      totalCompleted: json['totalCompleted'],
      xp: json['xp'],
      currentStreak: json['currentStreak'],
      longestStreak: json['longestStreak'],
      // ← ADD THESE
      year: json['year'],
      college: json['college'],
      studyMode: json['studyMode'],
      examTarget: json['examTarget'],
    );
  }
}
