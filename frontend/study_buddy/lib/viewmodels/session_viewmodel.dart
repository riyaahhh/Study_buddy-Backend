import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../services/api_service.dart';
import '../data/dummy_data.dart';

class SessionViewModel extends ChangeNotifier {
  List<SessionModel> _allSessions = [];
  List<SessionModel> _mySessions = [];
  bool _isLoading = false;
  String? _error;

  List<SessionModel> get allSessions => _allSessions;
  List<SessionModel> get mySessions => _mySessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchAllSessions({bool forceRefresh = false}) async {
    _setLoading(true);
    try {
      final data = await ApiService.getAllSessions(forceRefresh: forceRefresh);
      final realSessions = data.map((s) => SessionModel.fromJson(s)).toList();
      final realIds = realSessions.map((s) => s.id).toSet();
      final dummyFiltered =
          DummyData.sessions.where((s) => !realIds.contains(s.id)).toList();
      _allSessions = [...realSessions, ...dummyFiltered];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _allSessions = DummyData.sessions;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMySessions({bool forceRefresh = false}) async {
    _setLoading(true);
    try {
      final data = await ApiService.getMySessions(forceRefresh: forceRefresh);
      _mySessions = data.map((s) => SessionModel.fromJson(s)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load my sessions';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fix: now returns SessionModel instead of bool
  Future<SessionModel?> createSession(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final response = await ApiService.createSession(data);
      print('CREATE SESSION RESPONSE: $response'); // ← add this
      final newSession = SessionModel.fromJson(response);
      _mySessions = [newSession, ..._mySessions];
      _allSessions = [newSession, ..._allSessions];
      _isLoading = false;
      notifyListeners();
      fetchAllSessions(forceRefresh: true);
      fetchMySessions(forceRefresh: true);
      return newSession;
    } catch (e) {
      print('CREATE SESSION ERROR: $e'); // ← add this
      _error = 'Failed to create session';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> joinSession(String sessionId) async {
    if (sessionId.startsWith('dummy-')) {
      notifyListeners();
      return;
    }
    try {
      await ApiService.joinSession(sessionId);
      // refresh my sessions after joining
      await fetchMySessions(forceRefresh: true);
    } catch (e) {
      _error = 'Failed to join session';
      notifyListeners();
    }
  }

  Future<void> leaveSession(String sessionId) async {
    if (sessionId.startsWith('dummy-')) return;
    try {
      await ApiService.leaveSession(sessionId);
      await fetchMySessions(forceRefresh: true);
    } catch (e) {
      _error = 'Failed to leave session';
      notifyListeners();
    }
  }
}
