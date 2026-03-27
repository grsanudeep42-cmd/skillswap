import 'user_model.dart';

class MessageModel {
  final String id;
  final String content;
  final String matchId;
  final UserModel sender;
  final bool read;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.content,
    required this.matchId,
    required this.sender,
    this.read = false,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      matchId: json['matchId']?.toString() ?? json['match']?.toString() ?? '',
      sender: json['sender'] is Map<String, dynamic>
          ? UserModel.fromJson(json['sender'] as Map<String, dynamic>)
          : UserModel(id: json['sender']?.toString() ?? '', name: '', email: ''),
      read: json['read'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
