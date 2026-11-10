// lib/models/user_model.dart
class UserModel {
  final int id;
  final String name;
  final String email;

  const UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String,
        email: j['email'] as String,
      );
}
