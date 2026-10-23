import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/features/auth/data/mappers/app_user_mapper.dart';
import 'package:mavie/features/auth/domain/entities/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('toAppUser carries over id and email', () {
    const user = User(
      id: 'u1',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      email: 'a@mavie.app',
      createdAt: '2026-10-22T00:00:00Z',
    );

    expect(toAppUser(user), const AppUser(id: 'u1', email: 'a@mavie.app'));
  });

  test('toAppUser carries a null email through', () {
    const user = User(
      id: 'u1',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-10-22T00:00:00Z',
    );

    expect(toAppUser(user), const AppUser(id: 'u1'));
  });
}
