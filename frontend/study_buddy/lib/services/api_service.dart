import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'https://study-buddy-backend-1-ctpv.onrender.com';

  // timeout — don't hang forever
  static const Duration _timeout = Duration(seconds: 15);

  // simple in-memory cache
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTime = {};
  static Future<Map<String, dynamic>>? _profileRequest;
  static const Duration _cacheDuration = Duration(minutes: 5);

  static bool _isCacheValid(String key) {
    if (!_cache.containsKey(key)) return false;
    final time = _cacheTime[key];
    if (time == null) return false;
    return DateTime.now().difference(time) < _cacheDuration;
  }

  static void _setCache(String key, dynamic value) {
    _cache[key] = value;
    _cacheTime[key] = DateTime.now();
  }

  static void _removeCache(String key) {
    _cache.remove(key);
    _cacheTime.remove(key);
  }

  static void clearCache() {
    _cache.clear();
    _cacheTime.clear();
  }

  // ─── TOKEN ────────────────────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    clearCache();
  }

  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    if (token == null || token.trim().isEmpty) {
      throw const ApiException(
        'Your session has expired. Please sign in again.',
        statusCode: 401,
      );
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token.trim()}',
    };
  }

  // ─── WAKE UP RENDER ──────────────────────────────────────────
  // Call this on app start to wake up the server in background
  static Future<void> warmUp() async {
    try {
      await http
          .get(Uri.parse('$baseUrl/api/auth/login'))
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      // ignore — just waking up the server
    }
  }

  // ─── AUTH ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/auth/signup'),
          headers: {'Content-Type': 'application/json'},
          body:
              jsonEncode({'name': name, 'email': email, 'password': password}),
        )
        .timeout(_timeout);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(_timeout);
    return jsonDecode(response.body);
  }

  // ─── USER ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getMyProfile(
      {bool forceRefresh = false}) async {
    const cacheKey = 'my_profile';
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      return _cache[cacheKey];
    }

    // Home and Profile are initialized together. Reuse the same request instead
    // of making two calls while the backend is waking up.
    final pending = _profileRequest;
    if (pending != null) return pending;

    final request = _loadMyProfile(cacheKey);
    _profileRequest = request;
    try {
      return await request;
    } finally {
      if (identical(_profileRequest, request)) _profileRequest = null;
    }
  }

  static Future<Map<String, dynamic>> _loadMyProfile(String cacheKey) async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/users/me'), headers: await authHeaders())
        .timeout(_timeout);

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          decoded is Map<String, dynamic> ? decoded['error']?.toString() : null;
      throw ApiException(
        message ?? 'Could not load profile.',
        statusCode: response.statusCode,
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('Invalid profile response from server.');
    }
    _setCache(cacheKey, decoded);
    return decoded;
  }

  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/api/users/me'),
          headers: await authHeaders(),
          body: jsonEncode(data),
        )
        .timeout(_timeout);

    final raw = response.body;
    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final msgFromJson =
          decoded is Map<String, dynamic> ? decoded['error']?.toString() : null;
      final message =
          msgFromJson ?? (raw.isNotEmpty ? raw : 'Could not update profile.');
      throw ApiException('HTTP ${response.statusCode}: $message');
    }

    if (decoded is! Map<String, dynamic>) {
      // server returned something unexpected, surface raw body for debugging
      throw ApiException('Invalid profile response from server: $raw');
    }

    _removeCache('my_profile');
    _removeCache('gamification');
    _removeCache('leaderboard');
    _setCache('my_profile', decoded);
    return decoded;
  }

  static Future<List<dynamic>> getNearbyUsers({
    required double lat,
    required double lng,
    double radius = 5,
    bool forceRefresh = false,
  }) async {
    final cacheKey =
        'nearby_${lat.toStringAsFixed(2)}_${lng.toStringAsFixed(2)}';
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      return _cache[cacheKey];
    }
    final response = await http
        .get(
          Uri.parse(
              '$baseUrl/api/users/nearby?lat=$lat&lng=$lng&radius=$radius'),
          headers: await authHeaders(),
        )
        .timeout(_timeout);
    final data = jsonDecode(response.body);
    _setCache(cacheKey, data);
    return data;
  }

  // ─── SESSIONS ─────────────────────────────────────────────────
  static Future<List<dynamic>> getAllSessions(
      {bool forceRefresh = false}) async {
    const cacheKey = 'all_sessions';
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      return _cache[cacheKey];
    }
    final response = await http
        .get(Uri.parse('$baseUrl/api/sessions'), headers: await authHeaders())
        .timeout(_timeout);
    final data = jsonDecode(response.body);
    _setCache(cacheKey, data);
    return data;
  }

  static Future<List<dynamic>> getMySessions(
      {bool forceRefresh = false}) async {
    const cacheKey = 'my_sessions';
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      return _cache[cacheKey];
    }
    final response = await http
        .get(Uri.parse('$baseUrl/api/sessions/my'),
            headers: await authHeaders())
        .timeout(_timeout);
    final data = jsonDecode(response.body);
    _setCache(cacheKey, data);
    return data;
  }

  static Future<Map<String, dynamic>> createSession(
      Map<String, dynamic> data) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/sessions'),
          headers: await authHeaders(),
          body: jsonEncode(data),
        )
        .timeout(_timeout);
    _cache.remove('all_sessions');
    _cache.remove('my_sessions');
    return jsonDecode(response.body);
  }

  static Future<void> joinSession(String sessionId) async {
    await http
        .post(
          Uri.parse('$baseUrl/api/sessions/$sessionId/join'),
          headers: await authHeaders(),
        )
        .timeout(_timeout);
    _cache.remove('my_sessions');
    _cache.remove('gamification');
    _cache.remove('leaderboard');
  }

  static Future<void> leaveSession(String sessionId) async {
    await http
        .delete(
          Uri.parse('$baseUrl/api/sessions/$sessionId/leave'),
          headers: await authHeaders(),
        )
        .timeout(_timeout);
    _cache.remove('my_sessions');
  }

  // ─── MESSAGES ─────────────────────────────────────────────────
  static Future<List<dynamic>> getMessages(String sessionId) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/sessions/$sessionId/messages'),
          headers: await authHeaders(),
        )
        .timeout(_timeout);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/sessions/$sessionId/messages'),
          headers: await authHeaders(),
          body: jsonEncode({'content': content}),
        )
        .timeout(_timeout);
    return jsonDecode(response.body);
  }

  // ─── RELIABILITY ──────────────────────────────────────────────
  static Future<String> checkIn(String sessionId) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/sessions/$sessionId/checkin'),
          headers: await authHeaders(),
        )
        .timeout(_timeout);
    _cache.remove('gamification');
    _cache.remove('leaderboard');
    return response.body;
  }

  static Future<String> completeSession(String sessionId) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/sessions/$sessionId/complete'),
          headers: await authHeaders(),
        )
        .timeout(_timeout);
    _cache.remove('my_profile');
    _cache.remove('gamification');
    _cache.remove('leaderboard');
    return response.body;
  }

  // ─── GAMIFICATION ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getGamification({
    bool forceRefresh = false,
  }) async {
    const cacheKey = 'gamification';
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      return _cache[cacheKey];
    }
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/gamification/me'),
          headers: await authHeaders(),
        )
        .timeout(_timeout);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _setCache(cacheKey, data);
    return data;
  }

  static Future<List<dynamic>> getLeaderboard({
    bool forceRefresh = false,
  }) async {
    const cacheKey = 'leaderboard';
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      return _cache[cacheKey];
    }
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/gamification/leaderboard'),
          headers: await authHeaders(),
        )
        .timeout(_timeout);
    final data = jsonDecode(response.body) as List<dynamic>;
    _setCache(cacheKey, data);
    return data;
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
