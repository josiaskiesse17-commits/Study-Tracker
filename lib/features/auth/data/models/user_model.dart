import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
  });

  factory UserModel.fromFirebase(firebase_auth.User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      fullName: user.displayName,
    );
  }
}