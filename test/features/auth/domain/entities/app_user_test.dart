import 'package:flutter_test/flutter_test.dart';
import 'package:mavie/features/auth/domain/entities/app_user.dart';

void main() {
  test('two AppUsers with the same id and email are equal', () {
    const a = AppUser(id: 'u1', email: 'a@mavie.app');
    const b = AppUser(id: 'u1', email: 'a@mavie.app');

    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });

  test('AppUsers with different ids are not equal', () {
    const a = AppUser(id: 'u1', email: 'a@mavie.app');
    const b = AppUser(id: 'u2', email: 'a@mavie.app');

    expect(a, isNot(b));
  });
}
