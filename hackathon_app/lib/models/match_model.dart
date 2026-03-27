import 'user_model.dart';

class MatchModel {
  final String id;
  final String status;
  final String requesterSkillOffered;
  final String receiverSkillOffered;
  final String message;
  final UserModel requester;
  final UserModel receiver;
  final int matchScore;
  final DateTime createdAt;

  const MatchModel({
    required this.id,
    required this.status,
    this.requesterSkillOffered = '',
    this.receiverSkillOffered = '',
    this.message = '',
    required this.requester,
    required this.receiver,
    this.matchScore = 0,
    required this.createdAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      requesterSkillOffered: json['requesterSkillOffered']?.toString() ?? '',
      receiverSkillOffered: json['receiverSkillOffered']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      requester: json['requester'] is Map<String, dynamic>
          ? UserModel.fromJson(json['requester'] as Map<String, dynamic>)
          : UserModel(id: json['requester']?.toString() ?? '', name: '', email: ''),
      receiver: json['receiver'] is Map<String, dynamic>
          ? UserModel.fromJson(json['receiver'] as Map<String, dynamic>)
          : UserModel(id: json['receiver']?.toString() ?? '', name: '', email: ''),
      matchScore: (json['matchScore'] is num) ? (json['matchScore'] as num).toInt() : 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
