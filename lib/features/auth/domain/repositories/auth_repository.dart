import '../../../../core/error/result.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<Result<AppUser>> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> signOut();
}
