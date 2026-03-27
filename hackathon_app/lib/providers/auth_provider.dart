import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_service.dart';
import '../core/socket_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  final SocketService _socket = SocketService();

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null && _currentUser != null;
  String? get error => _error;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      try {
        _currentUser = await _api.getMe();
        _socket.connect(_token!);
      } catch (e) {
        _token = null;
        await prefs.remove('token');
      }
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.login(email, password);
      _token = data['token']?.toString();
      if (_token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        final userData = data['user'] ?? data['data'];
        if (userData is Map<String, dynamic>) {
          _currentUser = UserModel.fromJson(userData);
        } else {
          _currentUser = await _api.getMe();
        }
        _socket.connect(_token!);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    List<String> offered,
    List<String> wanted,
    String bio,
    String location,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.register(name, email, password, offered, wanted, bio, location);
      _token = data['token']?.toString();
      if (_token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        final userData = data['user'] ?? data['data'];
        if (userData is Map<String, dynamic>) {
          _currentUser = UserModel.fromJson(userData);
        } else {
          _currentUser = await _api.getMe();
        }
        _socket.connect(_token!);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUser() async {
    try {
      _currentUser = await _api.getMe();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _api.updateProfile(data);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _token = null;
    _currentUser = null;
    _socket.disconnect();
    notifyListeners();
  }
}
