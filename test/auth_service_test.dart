import 'package:flutter_test/flutter_test.dart';
import 'package:movemate/services/auth_service.dart';

void main() {
  late AuthService auth;

  setUp(() {
    // Create a fresh instance for each test by using the private constructor
    // via the factory. We reset state by rebuilding the singleton manually.
    auth = AuthService.createFresh();
  });

  // ── UC-1: User Registration ────────────────────────────────────────────────

  group('UC-1 User Registration', () {
    test('successful registration returns success and assigns unique ID', () {
      final result = auth.register(
        fullName: 'Alice Commuter',
        email: 'alice@example.com',
        password: 'Secure@123',
      );

      expect(result.success, isTrue);
      expect(result.user, isNotNull);
      expect(result.user!.id, isNotEmpty);
      expect(result.user!.email, equals('alice@example.com'));
      expect(result.user!.fullName, equals('Alice Commuter'));
    });

    test('BR-001: duplicate email is rejected', () {
      auth.register(fullName: 'Alice', email: 'alice@example.com', password: 'Secure@123');
      final result = auth.register(fullName: 'Alice2', email: 'alice@example.com', password: 'Secure@123');

      expect(result.success, isFalse);
      expect(result.message, contains('already exists'));
    });

    test('BR-002: weak password is rejected', () {
      final result = auth.register(fullName: 'Bob', email: 'bob@example.com', password: 'password');

      expect(result.success, isFalse);
    });

    test('missing full name is rejected', () {
      final result = auth.register(fullName: '', email: 'bob@example.com', password: 'Secure@123');
      expect(result.success, isFalse);
    });

    test('invalid email format is rejected', () {
      final result = auth.register(fullName: 'Bob', email: 'not-an-email', password: 'Secure@123');
      expect(result.success, isFalse);
    });

    test('BR-003: registration event is logged', () {
      auth.register(fullName: 'Alice', email: 'alice@example.com', password: 'Secure@123');
      final log = auth.auditLog;

      expect(log, isNotEmpty);
      expect(log.first['event'], equals('REGISTER'));
    });

    test('email is case-insensitively unique', () {
      auth.register(fullName: 'Alice', email: 'Alice@Example.com', password: 'Secure@123');
      final result = auth.register(fullName: 'Alice2', email: 'alice@example.com', password: 'Secure@123');

      expect(result.success, isFalse);
    });
  });

  // ── UC-2: User Authentication ──────────────────────────────────────────────

  group('UC-2 User Authentication', () {
    setUp(() {
      auth.register(fullName: 'Alice', email: 'alice@example.com', password: 'Secure@123');
    });

    test('BR-004: correct credentials grant access', () {
      final result = auth.login(email: 'alice@example.com', password: 'Secure@123');

      expect(result.success, isTrue);
      expect(auth.currentUser, isNotNull);
      expect(auth.currentUser!.email, equals('alice@example.com'));
    });

    test('wrong password is rejected', () {
      final result = auth.login(email: 'alice@example.com', password: 'WrongPass@1');

      expect(result.success, isFalse);
      expect(auth.currentUser, isNull);
    });

    test('unknown email is rejected', () {
      final result = auth.login(email: 'unknown@example.com', password: 'Secure@123');

      expect(result.success, isFalse);
    });

    test('logout clears current user', () {
      auth.login(email: 'alice@example.com', password: 'Secure@123');
      auth.logout();

      expect(auth.currentUser, isNull);
    });

    test('failed login attempt is logged', () {
      auth.login(email: 'alice@example.com', password: 'wrong');
      final failedLogs = auth.auditLog.where((e) => e['event'] == 'LOGIN_FAILED').toList();

      expect(failedLogs, isNotEmpty);
    });
  });

  // ── UC-3: Password Recovery ────────────────────────────────────────────────

  group('UC-3 Password Recovery', () {
    setUp(() {
      auth.register(fullName: 'Alice', email: 'alice@example.com', password: 'Secure@123');
    });

    test('BR-007: only registered users can request reset', () {
      final result = auth.requestPasswordReset(email: 'nobody@example.com');
      expect(result.success, isFalse);
    });

    test('reset code is generated for registered email', () {
      final result = auth.requestPasswordReset(email: 'alice@example.com');
      expect(result.success, isTrue);
      expect(auth.getVerificationCode('alice@example.com'), isNotNull);
    });

    test('correct code passes verification', () {
      auth.requestPasswordReset(email: 'alice@example.com');
      final code = auth.getVerificationCode('alice@example.com')!;

      final result = auth.verifyResetCode(email: 'alice@example.com', code: code);
      expect(result.success, isTrue);
    });

    test('wrong code fails verification', () {
      auth.requestPasswordReset(email: 'alice@example.com');

      final result = auth.verifyResetCode(email: 'alice@example.com', code: '000000');
      expect(result.success, isFalse);
    });

    test('BR-009: new password must meet security standards', () {
      auth.requestPasswordReset(email: 'alice@example.com');
      final code = auth.getVerificationCode('alice@example.com')!;

      final result = auth.resetPassword(
        email: 'alice@example.com',
        code: code,
        newPassword: 'weak',
      );
      expect(result.success, isFalse);
    });

    test('valid reset allows login with new password', () {
      auth.requestPasswordReset(email: 'alice@example.com');
      final code = auth.getVerificationCode('alice@example.com')!;

      final resetResult = auth.resetPassword(
        email: 'alice@example.com',
        code: code,
        newPassword: 'NewSecure@456',
      );
      expect(resetResult.success, isTrue);

      // Old password no longer works
      expect(auth.login(email: 'alice@example.com', password: 'Secure@123').success, isFalse);

      // New password works
      expect(auth.login(email: 'alice@example.com', password: 'NewSecure@456').success, isTrue);
    });

    test('BR-010: recovery event is logged', () {
      auth.requestPasswordReset(email: 'alice@example.com');
      final code = auth.getVerificationCode('alice@example.com')!;
      auth.resetPassword(email: 'alice@example.com', code: code, newPassword: 'NewSecure@456');

      final recoveryLogs = auth.auditLog.where((e) => e['event'] == 'PASSWORD_RESET').toList();
      expect(recoveryLogs, isNotEmpty);
    });
  });
}
