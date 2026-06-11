import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.login(
        email: email,
        password: password,
      );
      if (response['token'] != null) {
        await ApiService.saveToken(response['token']);
        await ApiService.saveUserId(response['userId']);
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Something went wrong. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.signup(
        name: name,
        email: email,
        password: password,
      );
      if (response['userId'] != null) {
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Signup failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Something went wrong. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.clearStorage();
  }
}
