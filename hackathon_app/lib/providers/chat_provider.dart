import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/socket_service.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  final SocketService _socket = SocketService();

  List<MessageModel> _messages = [];
  bool _isTyping = false;
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  void setCurrentUser(String userId) {
    _currentUserId = userId;
  }

  List<MessageModel> get messages => _messages;
  bool get isTyping => _isTyping;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHistory(String matchId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _messages = await _api.getChatHistory(matchId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void joinChat(String matchId) {
    _socket.offMessage();
    _socket.offTyping();
    _socket.joinChat(matchId);
    _socket.onMessage((data) {
      if (data is Map<String, dynamic>) {
        final message = MessageModel.fromJson(data);
        print("INCOMING sender: ${message.sender.id}, content: ${message.content}");
        print("LOCAL messages: ${_messages.map((m) => "${m.sender.id}:${m.content}").toList()}");
        final isDuplicate = _messages.any((m) =>
          m.content == message.content &&
          message.createdAt.difference(m.createdAt).inSeconds.abs() < 10 &&
          m.matchId == message.matchId
        );
        if (!isDuplicate) {
          _messages.add(message);
          notifyListeners();
        }
      }
    });
    _socket.onTyping((data) {
      if (data is Map<String, dynamic>) {
        _isTyping = data['isTyping'] == true;
        notifyListeners();
      }
    });
  }

  void sendMessage(String matchId, String receiverId, String content) {
    _socket.sendMessage(matchId, receiverId, content);
    final localMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      matchId: matchId,
      sender: UserModel(id: _currentUserId ?? 'me', name: '', email: ''),
      read: false,
      createdAt: DateTime.now(),
    );
    _messages.add(localMessage);
    notifyListeners();
  }

  void setTyping(String matchId, bool typing) {
    _socket.emitTyping(matchId, typing);
  }

  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _api.getUnreadCount();
      notifyListeners();
    } catch (_) {
      // Silently fail for unread count
    }
  }

  void leaveChat() {
    _socket.offMessage();
    _socket.offTyping();
    _messages = [];
    _isTyping = false;
    notifyListeners();
  }
}
