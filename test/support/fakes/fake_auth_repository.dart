import 'package:mavie/core/error/result.dart';
import 'package:mavie/features/auth/domain/entities/app_user.dart';
import 'package:mavie/features/auth/domain/repositories/auth_repository.dart';

/// A fake drifting from [AuthRepository] is a compile error, same as
/// [FakeMovieRepository] — configurable results, call-count spies, and the
/// last arguments each method was called with.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.signUpResult,
    this.signInResult,
    this.sendPasswordResetEmailResult,
    this.signOutResult,
  });

  Result<AppUser>? signUpResult;
  Result<AppUser>? signInResult;
  Result<void>? sendPasswordResetEmailResult;
  Result<void>? signOutResult;

  int signUpCallCount = 0;
  int signInCallCount = 0;
  int sendPasswordResetEmailCallCount = 0;
  int signOutCallCount = 0;

  String? lastEmail;
  String? lastPassword;

  @override
  Future<Result<AppUser>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    signUpCallCount++;
    lastEmail = email;
    lastPassword = password;
    return signUpResult ?? Ok(AppUser(id: 'fake-id', email: email));
  }

  @override
  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    signInCallCount++;
    lastEmail = email;
    lastPassword = password;
    return signInResult ?? Ok(AppUser(id: 'fake-id', email: email));
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    sendPasswordResetEmailCallCount++;
    lastEmail = email;
    return sendPasswordResetEmailResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> signOut() async {
    signOutCallCount++;
    return signOutResult ?? const Ok(null);
  }
}
