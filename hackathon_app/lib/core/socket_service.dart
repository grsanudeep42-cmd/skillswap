import 'package:socket_io_client/socket_io_client.dart' as io;
import 'constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String token) {
    _socket?.disconnect();
    _socket = io.io(socketUrl, io.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': token})
      .disableAutoConnect()
      .build(),
    );
    _socket!.connect();

    _socket!.onConnect((_) {
      // Connected to socket server
    });

    _socket!.onDisconnect((_) {
      // Disconnected from socket server
    });

    _socket!.onConnectError((data) {
      // Connection error
    });
  }

  void joinChat(String matchId) {
    _socket?.emit('join_chat', matchId);
  }

  void sendMessage(String matchId, String receiverId, String content) {
    _socket?.emit('send_message', {
      'matchId': matchId,
      'receiverId': receiverId,
      'content': content,
    });
  }

  void emitTyping(String matchId, bool isTyping) {
    _socket?.emit('typing', {
      'matchId': matchId,
      'isTyping': isTyping,
    });
  }

  void onMessage(Function(dynamic) callback) {
    _socket?.on('receive_message', callback);
  }

  void onTyping(Function(dynamic) callback) {
    _socket?.on('user_typing', callback);
  }

  void onUserOnline(Function(dynamic) callback) {
    _socket?.on('user_online', callback);
  }

  void onUserOffline(Function(dynamic) callback) {
    _socket?.on('user_offline', callback);
  }

  void offMessage() {
    _socket?.off('receive_message');
  }

  void offTyping() {
    _socket?.off('user_typing');
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
