import 'package:flutter_test/flutter_test.dart';
import 'package:study_buddy/models/gamification_model.dart';

void main() {
  test('parses gamification profile data', () {
    final model = GamificationModel.fromJson({
      'xp': 340,
      'currentStreak': 4,
      'longestStreak': 8,
      'badges': ['Bronze Scholar', 'Silver Scholar'],
      'weeklyXp': 95,
      'weeklyRank': 2,
      'college': 'VIT Pune',
    });

    expect(model.xp, 340);
    expect(model.currentStreak, 4);
    expect(model.badges, contains('Silver Scholar'));
    expect(model.weeklyRank, 2);
  });

  test('parses leaderboard entries with safe defaults', () {
    final entry = LeaderboardEntryModel.fromJson({
      'userId': 'student-1',
      'name': 'Riya',
      'rank': 1,
      'weeklyXp': 120,
      'totalXp': 500,
    });

    expect(entry.name, 'Riya');
    expect(entry.weeklyXp, 120);
    expect(entry.badges, isEmpty);
  });
}
