import 'user_model.dart';

class SessionModel {
  final String id;
  final int duration;
  final String notes;
  final String loggedBy;
  final DateTime createdAt;

  const SessionModel({
    required this.id,
    required this.duration,
    this.notes = '',
    this.loggedBy = '',
    required this.createdAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      duration: (json['duration'] is num) ? (json['duration'] as num).toInt() : 0,
      notes: json['notes']?.toString() ?? '',
      loggedBy: json['loggedBy']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class ExchangeModel {
  final String id;
  final String status;
  final String skill1;
  final String skill2;
  final UserModel user1;
  final UserModel user2;
  final double user1Progress;
  final double user2Progress;
  final int totalSessions;
  final int targetSessions;
  final List<SessionModel> sessions;

  const ExchangeModel({
    required this.id,
    required this.status,
    this.skill1 = '',
    this.skill2 = '',
    required this.user1,
    required this.user2,
    this.user1Progress = 0.0,
    this.user2Progress = 0.0,
    this.totalSessions = 0,
    this.targetSessions = 10,
    this.sessions = const [],
  });

  factory ExchangeModel.fromJson(Map<String, dynamic> json) {
    return ExchangeModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      skill1: json['skill1']?.toString() ?? '',
      skill2: json['skill2']?.toString() ?? '',
      user1: json['user1'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user1'] as Map<String, dynamic>)
          : UserModel(id: json['user1']?.toString() ?? '', name: '', email: ''),
      user2: json['user2'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user2'] as Map<String, dynamic>)
          : UserModel(id: json['user2']?.toString() ?? '', name: '', email: ''),
      user1Progress: (json['user1Progress'] is num) ? (json['user1Progress'] as num).toDouble() : 0.0,
      user2Progress: (json['user2Progress'] is num) ? (json['user2Progress'] as num).toDouble() : 0.0,
      totalSessions: (json['totalSessions'] is num) ? (json['totalSessions'] as num).toInt() : 0,
      targetSessions: (json['targetSessions'] is num) ? (json['targetSessions'] as num).toInt() : 10,
      sessions: (json['sessions'] is List)
          ? (json['sessions'] as List)
              .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}
