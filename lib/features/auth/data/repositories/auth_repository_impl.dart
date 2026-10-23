import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../mappers/app_user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient client;

  AuthRepositoryImpl(this.client);

  @override
  Future<Result<AppUser>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return Err(
          UnknownFailure(
            StateError('Supabase signUp returned no user'),
            StackTrace.current,
          ),
        );
      }
      return Ok(toAppUser(user));
    } catch (error, stackTrace) {
      return Err(mapExceptionToFailure(error, stackTrace));
    }
  }

  @override
  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return Err(
          UnknownFailure(
            StateError('Supabase signInWithPassword returned no user'),
            StackTrace.current,
          ),
        );
      }
      return Ok(toAppUser(user));
    } catch (error, stackTrace) {
      return Err(mapExceptionToFailure(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
      return const Ok(null);
    } catch (error, stackTrace) {
      return Err(mapExceptionToFailure(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await client.auth.signOut();
      return const Ok(null);
    } catch (error, stackTrace) {
      return Err(mapExceptionToFailure(error, stackTrace));
    }
  }
}
