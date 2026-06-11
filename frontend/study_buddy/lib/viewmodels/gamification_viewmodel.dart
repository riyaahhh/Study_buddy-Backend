import 'package:flutter/material.dart';

import '../models/gamification_model.dart';
import '../services/api_service.dart';

class GamificationViewModel extends ChangeNotifier {
  GamificationModel? _profile;
  List<LeaderboardEntryModel> _leaderboard = [];
  bool _isLoading = false;
  String? _error;

  GamificationModel? get profile => _profile;
  List<LeaderboardEntryModel> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchGamification({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        ApiService.getGamification(forceRefresh: forceRefresh),
        ApiService.getLeaderboard(forceRefresh: forceRefresh),
      ]);
      _profile = GamificationModel.fromJson(
        results[0] as Map<String, dynamic>,
      );
      _leaderboard = (results[1] as List<dynamic>)
          .map(
            (entry) => LeaderboardEntryModel.fromJson(
              entry as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (_) {
      _error = 'Could not load gamification details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
