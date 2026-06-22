import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../data/dummy_data.dart';

class UserViewModel extends ChangeNotifier {
  UserModel? _user;
  List<UserModel> _nearbyUsers = [];
  bool _isLoading = false;
  String? _error;
  int? _errorStatusCode;

  UserModel? get user => _user;
  List<UserModel> get nearbyUsers => _nearbyUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get errorStatusCode => _errorStatusCode;

  final String? year;
  final String? studyMode;
  final String? examTarget;
  final String? college;

  UserViewModel({this.year, this.studyMode, this.examTarget, this.college});

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchMyProfile({bool forceRefresh = false}) async {
    _setLoading(true);
    _error = null;
    _errorStatusCode = null;
    try {
      final data = await ApiService.getMyProfile(forceRefresh: forceRefresh);
      _user = UserModel.fromJson(data);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to load profile';
      _errorStatusCode = e is ApiException ? e.statusCode : null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;
    _errorStatusCode = null;
    try {
      await ApiService.updateProfile(data);
      final persisted = await ApiService.getMyProfile(forceRefresh: true);
      _user = UserModel.fromJson(persisted);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchNearbyUsers(
      {required double lat, required double lng}) async {
    _setLoading(true);
    try {
      final data = await ApiService.getNearbyUsers(lat: lat, lng: lng);
      final realUsers = data.map((u) => UserModel.fromJson(u)).toList();
      final realIds = realUsers.map((u) => u.id).toSet();
      final dummyFiltered =
          DummyData.nearbyUsers.where((u) => !realIds.contains(u.id)).toList();
      _nearbyUsers = [...realUsers, ...dummyFiltered];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _nearbyUsers = DummyData.nearbyUsers;
      _isLoading = false;
      notifyListeners();
    }
  }
}
