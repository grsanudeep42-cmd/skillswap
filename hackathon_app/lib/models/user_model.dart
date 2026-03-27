class UserModel {
  final String id;
  final String name;
  final String email;
  final String bio;
  final String location;
  final String avatar;
  final List<String> skillsOffered;
  final List<String> skillsWanted;
  final double rating;
  final int completedExchanges;
  final int totalRatings;
  final bool isOnline;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.bio = '',
    this.location = '',
    this.avatar = '',
    this.skillsOffered = const [],
    this.skillsWanted = const [],
    this.rating = 0.0,
    this.completedExchanges = 0,
    this.totalRatings = 0,
    this.isOnline = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      skillsOffered: _parseStringList(json['skillsOffered']),
      skillsWanted: _parseStringList(json['skillsWanted']),
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
      completedExchanges: (json['completedExchanges'] is num) ? (json['completedExchanges'] as num).toInt() : 0,
      totalRatings: (json['totalRatings'] is num) ? (json['totalRatings'] as num).toInt() : 0,
      isOnline: json['isOnline'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'bio': bio,
      'location': location,
      'avatar': avatar,
      'skillsOffered': skillsOffered,
      'skillsWanted': skillsWanted,
    };
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? bio,
    String? location,
    String? avatar,
    List<String>? skillsOffered,
    List<String>? skillsWanted,
    double? rating,
    int? completedExchanges,
    int? totalRatings,
    bool? isOnline,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      avatar: avatar ?? this.avatar,
      skillsOffered: skillsOffered ?? this.skillsOffered,
      skillsWanted: skillsWanted ?? this.skillsWanted,
      rating: rating ?? this.rating,
      completedExchanges: completedExchanges ?? this.completedExchanges,
      totalRatings: totalRatings ?? this.totalRatings,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
