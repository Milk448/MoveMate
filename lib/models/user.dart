/// Represents a registered user in the MoveMate system.
///
/// Satisfies BR-001 (unique email) and BR-003 (registration events logged).
class User {
  final String id;
  final String fullName;
  final String email;
  final String passwordHash;
  final DateTime createdAt;
  final bool isVerified;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    this.isVerified = false,
  });

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? passwordHash,
    DateTime? createdAt,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      passwordHash: map['passwordHash'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isVerified: map['isVerified'] as bool? ?? false,
    );
  }
}
