import '../constants/db_fields.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String avatarPath;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.avatarPath = ""
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map[UserFields.id].toString(),
      name: map[UserFields.name] ?? '',
      email: map[UserFields.email] ?? '',
      password: map[UserFields.password] ?? '',
      role: map[UserFields.role] ?? '',
      avatarPath: map[UserFields.avatarPath] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      UserFields.id: id,
      UserFields.name: name,
      UserFields.email: email,
      UserFields.password: password,
      UserFields.role: role,
      UserFields.avatarPath: avatarPath,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    String? avatarPath,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
