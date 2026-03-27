import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/exchange_model.dart';

class ExchangeProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<ExchangeModel> _exchanges = [];
  ExchangeModel? _currentExchange;
  bool _isLoading = false;
  String? _error;

  List<ExchangeModel> get exchanges => _exchanges;
  ExchangeModel? get currentExchange => _currentExchange;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get activeCount => _exchanges.where((e) => e.status == 'active').length;

  Future<void> fetchExchanges() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _exchanges = await _api.getExchanges();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchExchange(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentExchange = await _api.getExchange(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logSession(String exchangeId, int duration, String notes) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentExchange = await _api.logSession(exchangeId, duration, notes);
      final idx = _exchanges.indexWhere((e) => e.id == exchangeId);
      if (idx != -1 && _currentExchange != null) {
        _exchanges[idx] = _currentExchange!;
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

  Future<bool> rate(String exchangeId, int rating, String review) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentExchange = await _api.rateExchange(exchangeId, rating, review);
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
}
