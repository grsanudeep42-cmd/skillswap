import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/match_model.dart';

class MatchProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> _suggestions = [];
  List<MatchModel> _myMatches = [];
  List<MatchModel> _pendingMatches = [];
  List<MatchModel> _sentMatches = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get suggestions => _suggestions;
  List<MatchModel> get myMatches => _myMatches;
  List<MatchModel> get pendingMatches => _pendingMatches;
  List<MatchModel> get sentMatches => _sentMatches;
  List<MatchModel> get acceptedMatches =>
      _myMatches.where((m) => m.status == 'accepted').toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get pendingCount => _pendingMatches.length;

  Future<void> fetchSuggestions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _suggestions = await _api.getMatchSuggestions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSuggestionsWithFallback() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _suggestions = await _api.getMatchSuggestions();
      // If suggestions empty, fall back to browse
      if (_suggestions.isEmpty) {
        final users = await _api.browseSkills();
        _suggestions = users.map((u) => {
          '_id': u.id,
          'name': u.name,
          'email': u.email,
          'location': u.location,
          'bio': u.bio,
          'skillsOffered': u.skillsOffered,
          'skillsWanted': u.skillsWanted,
        }).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // If suggestions endpoint fails entirely, try browse
      try {
        final users = await _api.browseSkills();
        _suggestions = users.map((u) => {
          '_id': u.id,
          'name': u.name,
          'email': u.email,
          'location': u.location,
          'bio': u.bio,
          'skillsOffered': u.skillsOffered,
          'skillsWanted': u.skillsWanted,
        }).toList();
        _isLoading = false;
        notifyListeners();
      } catch (e2) {
        _error = e2.toString();
        _isLoading = false;
        notifyListeners();
      }
    }
  }


  Future<void> fetchMatches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _myMatches = await _api.getMatches();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPending() async {
    try {
      _pendingMatches = await _api.getPendingMatches();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> fetchSent() async {
    try {
      _sentMatches = await _api.getSentMatches();
      notifyListeners();
    } catch (e) {
      _sentMatches = [];
      notifyListeners();
    }
  }

  Future<bool> sendRequest(
    String receiverId,
    String mySkill,
    String theirSkill,
    String message,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _api.sendMatchRequest(receiverId, mySkill, theirSkill, message);
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

  Future<bool> respond(String matchId, String status) async {
    try {
      await _api.respondToMatch(matchId, status);
      await fetchPending();
      await fetchSent();
      await fetchMatches();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
