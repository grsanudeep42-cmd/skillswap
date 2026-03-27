import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/match_model.dart';
import '../models/exchange_model.dart';
import '../models/message_model.dart';
import 'constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      throw ApiException('Session expired. Please login again.', 401);
    }
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final message = body['message']?.toString() ?? body['error']?.toString() ?? 'Something went wrong';
    throw ApiException(message, response.statusCode);
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = await _handleResponse(response);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    List<String> offered,
    List<String> wanted,
    String bio,
    String location,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'skillsOffered': offered,
        'skillsWanted': wanted,
        'bio': bio,
        'location': location,
      }),
    );
    final data = await _handleResponse(response);
    return data as Map<String, dynamic>;
  }

  Future<UserModel> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: await _authHeaders(),
    );
    final data = await _handleResponse(response);
    if (data is Map<String, dynamic>) {
      final user = data['user'] ?? data['data'] ?? data;
      return UserModel.fromJson(user as Map<String, dynamic>);
    }
    throw ApiException('Invalid response format', 500);
  }

  Future<UserModel> updateProfile(Map<String, dynamic> profileData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/update-profile'),
      headers: await _authHeaders(),
      body: jsonEncode(profileData),
    );
    final data = await _handleResponse(response);
    if (data is Map<String, dynamic>) {
      final user = data['user'] ?? data['data'] ?? data;
      return UserModel.fromJson(user as Map<String, dynamic>);
    }
    throw ApiException('Invalid response format', 500);
  }

  /// Seeds 4 demo users when the platform has fewer than 3 users.
  /// Safe to call on every launch — no-ops if users already exist.
  Future<void> seedDemoUsers() async {
    try {
      final existing = await browseSkills();
      if (existing.length >= 3) return;

      final seeds = [
        {
          'name': 'Priya Sharma', 'email': 'priya.sharma@skillswap.dev',
          'password': 'Demo@1234', 'location': 'Delhi',
          'bio': 'Senior UX designer passionate about human-centered design and accessibility.',
          'skillsOffered': ['UI/UX Design', 'Figma'],
          'skillsWanted': ['Python', 'Machine Learning'],
        },
        {
          'name': 'Rahul Verma', 'email': 'rahul.verma@skillswap.dev',
          'password': 'Demo@1234', 'location': 'Bangalore',
          'bio': 'Backend engineer with 5 years in Python/Django. Love building scalable APIs.',
          'skillsOffered': ['Python', 'Django'],
          'skillsWanted': ['Mobile Development', 'Flutter'],
        },
        {
          'name': 'Aisha Khan', 'email': 'aisha.khan@skillswap.dev',
          'password': 'Demo@1234', 'location': 'Hyderabad',
          'bio': 'Digital marketing strategist helping brands grow through content and SEO.',
          'skillsOffered': ['Digital Marketing', 'SEO'],
          'skillsWanted': ['Web Development', 'React'],
        },
        {
          'name': 'Kiran Reddy', 'email': 'kiran.reddy@skillswap.dev',
          'password': 'Demo@1234', 'location': 'Chennai',
          'bio': 'Data scientist specializing in SQL analytics and business intelligence.',
          'skillsOffered': ['Data Science', 'SQL'],
          'skillsWanted': ['Communication', 'Public Speaking'],
        },
      ];

      for (final seed in seeds) {
        try {
          await http.post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(seed),
          );
        } catch (_) {
          // Ignore individual failures — user may already exist
        }
      }
    } catch (_) {
      // Silently no-op if backend is unreachable during seeding
    }
  }

  // ─── Skills / Browse ──────────────────────────────────────────────────────

  Future<List<UserModel>> browseSkills({String? search}) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    final uri = Uri.parse('$baseUrl/skills/browse').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _authHeaders());
    final data = await _handleResponse(response);
    final list = (data is Map<String, dynamic>)
        ? (data['users'] ?? data['data'] ?? data['skills'] ?? [])
        : data;
    if (list is List) {
      return list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/skills/categories'),
      headers: await _authHeaders(),
    );
    final data = await _handleResponse(response);
    final list = (data is Map<String, dynamic>)
        ? (data['categories'] ?? data['data'] ?? [])
        : data;
    if (list is List) {
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  // ─── Matches ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMatchSuggestions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/matches/suggestions'),
      headers: await _authHeaders(),
    );
    final data = await _handleResponse(response);
    final list = (data is Map<String, dynamic>)
        ? (data['suggestions'] ?? data['data'] ?? [])
        : data;
    if (list is List) {
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<MatchModel> sendMatchRequest(
    String receiverId,
    String mySkill,
    String theirSkill,
    String message,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/matches'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'receiverId': receiverId,
        'requesterSkillOffered': mySkill,
        'receiverSkillOffered': theirSkill,
        'message': message,
      }),
    );
    final data = await _handleResponse(response);
    final match = (data is Map<String, dynamic>)
        ? (data['match'] ?? data['data'] ?? data)
        : data;
    return MatchModel.fromJson(match as Map<String, dynamic>);
  }

  Future<List<MatchModel>> getMatches() async {
    final response = await http.get(
      Uri.parse('$baseUrl/matches'),
      headers: await _authHeaders(),
    );
    final data = await _handleResponse(response);
    final list = (data is Map<String, dynamic>)
        ? (data['matches'] ?? data['data'] ?? [])
        : data;
    if (list is List) {
      return list.map((e) => MatchModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<MatchModel>> getPendingMatches() async {
    final response = await http.get(
      Uri.parse('$baseUrl/matches/pending'),
      headers: await _authHeaders(),
    );
    final data = await _handleResponse(response);
    final list = (data is Map<String, dynamic>)
        ? (data['matches'] ?? data['data'] ?? [])
        : data;
    if (list is List) {
      return list.map((e) => MatchModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<MatchModel>> getSentMatches() async {
    final response = await http.get(
      Uri.parse('$baseUrl/matches/sent'),
      headers: await _authHeaders(),
    );
    final data = await _handleResponse(response);
    final list = (data is Map<String, dynamic>)
        ? (data['matches'] ?? data['data'] ?? [])
        : data;
    if (list is List) {
      return list.map((e) => MatchModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<MatchModel> respondToMatch(String matchId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/matches/$matchId/respond'),
      headers: await _authHeaders(),
      body: jsonEncode({'status': status}),
    );
    final data = await _handleResponse(response);
    final match = (data is Map<String, dynamic>)
        ? (data['match'] ?? data['data'] ?? data)
        : data;
    return MatchModel.fromJson(match as Map<String, dynamic>);
  }

  // ─── Exchanges ────────────────────────────────────────────────────────────

  Future<List<ExchangeModel>> getExchanges() async {
    final response = await http.get(
      Uri.parse('$baseUrl/exchanges'),
      headers: await _authHeaders(),
    );
    final data = await _handleResponse(response);
    final list = (data is Map<String, dynamic>)
        ? (data['exchanges'] ?? data['data'] ?? [])
        : data;
    if (list is List) {
      return list.map((e) => ExchangeModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<ExchangeModel> getExchange(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/exchanges/$id'),
      headers: await _authHeaders(),
    );
    final data = await _handleResponse(response);
    final exchange = (data is Map<String, dynamic>)
        ? (data['exchange'] ?? data['data'] ?? data)
        : data;
    return ExchangeModel.fromJson(exchange as Map<String, dynamic>);
  }

  Future<ExchangeModel> logSession(String exchangeId, int duration, String notes) async {
    final response = await http.post(
      Uri.parse('$baseUrl/exchanges/$exchangeId/sessions'),
      headers: await _authHeaders(),
      body: jsonEncode({'duration': duration, 'notes': notes}),
    );
    final data = await _handleResponse(response);
    final exchange = (data is Map<String, dynamic>)
        ? (data['exchange'] ?? data['data'] ?? data)
        : data;
    return ExchangeModel.fromJson(exchange as Map<String, dynamic>);
  }

  Future<ExchangeModel> rateExchange(String exchangeId, int rating, String review) async {
    final response = await http.post(
      Uri.parse('$baseUrl/exchanges/$exchangeId/rate'),
      headers: await _authHeaders(),
      body: jsonEncode({'rating': rating, 'review': review}),
    );
    final data = await _handleResponse(response);
    final exchange = (data is Map<String, dynamic>)
        ? (data['exchange'] ?? data['data'] ?? data)
        : data;
    return ExchangeModel.fromJson(exchange as Map<String, dynamic>);
  }

  // ─── Chat ─────────────────────────────────────────────────────────────────

  Future<List<MessageModel>> getChatHistory(String matchId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/$matchId'),
      headers: await _authHeaders(),
    );
    final data = await _handleResponse(response);
    final list = (data is Map<String, dynamic>)
        ? (data['messages'] ?? data['data'] ?? [])
        : data;
    if (list is List) {
      return list.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<int> getUnreadCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/unread/count'),
      headers: await _authHeaders(),
    );
    final data = await _handleResponse(response);
    if (data is Map<String, dynamic>) {
      return (data['count'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
