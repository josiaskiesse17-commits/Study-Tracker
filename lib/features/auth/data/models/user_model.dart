import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
  });

  factory UserModel.fromSupabase(
    String id,
    String email,
    Map<String, dynamic>? metadata,
  ) {
    return UserModel(
      id: id,
      email: email,
      fullName: metadata?['full_name'] as String?,
    );
  }
}