import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/user.dart';

/// Result type for auth operations.
class AuthResult {
  final bool success;
  final String? message;
  final User? user;

  const AuthResult({required this.success, this.message, this.user});
}

/// Manages user authentication state and operations.
///
/// Implements UC-1 (Registration), UC-2 (Login), and UC-3 (Password Recovery).
/// Satisfies BR-001 through BR-010.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Creates an isolated instance for testing purposes.
  @visibleForTesting
  factory AuthService.createFresh() => AuthService._internal();

  final _uuid = const Uuid();
  final Map<String, User> _users = {};
  final Map<String, String> _verificationCodes = {};
  final Map<String, DateTime> _codeExpiry = {};
  final List<Map<String, dynamic>> _auditLog = [];
  User? _currentUser;

  /// Returns the currently authenticated user, or null if not logged in.
  User? get currentUser => _currentUser;

  // ── UC-1: User Registration ────────────────────────────────────────────────

  /// Registers a new user with [fullName], [email], and [password].
  ///
  /// Validates uniqueness (BR-001), password strength (BR-002),
  /// assigns a unique ID, and logs the event (BR-003).
  AuthResult register({
    required String fullName,
    required String email,
    required String password,
  }) {
    final trimmedEmail = email.trim().toLowerCase();

    // Validate inputs
    if (fullName.trim().isEmpty) {
      return const AuthResult(success: false, message: 'Full name is required.');
    }
    if (!_isValidEmail(trimmedEmail)) {
      return const AuthResult(success: false, message: 'Enter a valid email address.');
    }
    if (!_isStrongPassword(password)) {
      return const AuthResult(
        success: false,
        message:
            'Password must be at least 8 characters and include uppercase, lowercase, digit, and special character.',
      );
    }

    // BR-001: Only unique email can register
    if (_users.containsKey(trimmedEmail)) {
      return const AuthResult(
        success: false,
        message: 'An account with this email already exists.',
      );
    }

    final now = DateTime.now();
    final user = User(
      id: _uuid.v4(),
      fullName: fullName.trim(),
      email: trimmedEmail,
      passwordHash: _hashPassword(password),
      createdAt: now,
    );

    _users[trimmedEmail] = user;

    // BR-003: Log registration event
    _log({'event': 'REGISTER', 'userId': user.id, 'email': trimmedEmail, 'timestamp': now.toIso8601String()});

    return AuthResult(success: true, message: 'Account created successfully.', user: user);
  }

  // ── UC-2: User Authentication ──────────────────────────────────────────────

  /// Authenticates a user with [email] and [password].
  ///
  /// Verifies credentials (BR-004) and logs the login event.
  AuthResult login({required String email, required String password}) {
    final trimmedEmail = email.trim().toLowerCase();
    final user = _users[trimmedEmail];

    if (user == null || user.passwordHash != _hashPassword(password)) {
      _log({'event': 'LOGIN_FAILED', 'email': trimmedEmail, 'timestamp': DateTime.now().toIso8601String()});
      return const AuthResult(success: false, message: 'Incorrect email or password.');
    }

    // AF-2: Unverified account check (optional for future email verification)
    _currentUser = user;
    _log({'event': 'LOGIN', 'userId': user.id, 'email': trimmedEmail, 'timestamp': DateTime.now().toIso8601String()});

    return AuthResult(success: true, message: 'Login successful.', user: user);
  }

  /// Logs out the current user.
  void logout() {
    if (_currentUser != null) {
      _log({'event': 'LOGOUT', 'userId': _currentUser!.id, 'timestamp': DateTime.now().toIso8601String()});
      _currentUser = null;
    }
  }

  // ── UC-3: Password Recovery ────────────────────────────────────────────────

  /// Initiates password recovery for [email] by generating a verification code.
  ///
  /// BR-007: Only registered users can recover passwords.
  /// BR-008: Verification codes expire after 10 minutes.
  AuthResult requestPasswordReset({required String email}) {
    final trimmedEmail = email.trim().toLowerCase();

    if (!_users.containsKey(trimmedEmail)) {
      return const AuthResult(success: false, message: 'No account found with this email.');
    }

    final code = _generateCode();
    _verificationCodes[trimmedEmail] = code;
    _codeExpiry[trimmedEmail] = DateTime.now().add(const Duration(minutes: 10));

    _log({'event': 'PASSWORD_RESET_REQUESTED', 'email': trimmedEmail, 'timestamp': DateTime.now().toIso8601String()});

    // In production this code would be emailed via mailTrap / email service.
    // Exposed here only for testing; UI should display a "check your email" message.
    return AuthResult(success: true, message: 'Verification code sent to $trimmedEmail.', user: null);
  }

  /// Verifies [code] for [email].
  ///
  /// BR-008: Codes expire after 10 minutes.
  AuthResult verifyResetCode({required String email, required String code}) {
    final trimmedEmail = email.trim().toLowerCase();
    final storedCode = _verificationCodes[trimmedEmail];
    final expiry = _codeExpiry[trimmedEmail];

    if (storedCode == null || expiry == null) {
      return const AuthResult(success: false, message: 'No reset code found. Please request a new one.');
    }
    if (DateTime.now().isAfter(expiry)) {
      _verificationCodes.remove(trimmedEmail);
      _codeExpiry.remove(trimmedEmail);
      return const AuthResult(success: false, message: 'Verification code has expired. Please request a new one.');
    }
    if (storedCode != code.trim()) {
      return const AuthResult(success: false, message: 'Invalid verification code. Please try again.');
    }

    return const AuthResult(success: true, message: 'Code verified.');
  }

  /// Resets the password for [email] after code verification.
  ///
  /// BR-009: New password must meet security standards.
  /// BR-010: Recovery events logged.
  AuthResult resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    final verifyResult = verifyResetCode(email: email, code: code);
    if (!verifyResult.success) return verifyResult;

    final trimmedEmail = email.trim().toLowerCase();
    if (!_isStrongPassword(newPassword)) {
      return const AuthResult(
        success: false,
        message:
            'Password must be at least 8 characters and include uppercase, lowercase, digit, and special character.',
      );
    }

    final existing = _users[trimmedEmail]!;
    _users[trimmedEmail] = existing.copyWith(passwordHash: _hashPassword(newPassword));
    _verificationCodes.remove(trimmedEmail);
    _codeExpiry.remove(trimmedEmail);

    // BR-010: Log recovery event
    _log({
      'event': 'PASSWORD_RESET',
      'userId': existing.id,
      'email': trimmedEmail,
      'timestamp': DateTime.now().toIso8601String(),
    });

    return const AuthResult(success: true, message: 'Password reset successfully.');
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// BR-002 / BR-009: Minimum 8 chars, upper, lower, digit, special char.
  bool _isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  String _generateCode() {
    final rng = Random.secure();
    return List.generate(6, (_) => rng.nextInt(10)).join();
  }

  void _log(Map<String, dynamic> entry) {
    _auditLog.add(entry);
  }

  /// Returns the audit log (for testing / admin review).
  List<Map<String, dynamic>> get auditLog => List.unmodifiable(_auditLog);

  /// Exposes verification code for testing only.
  @visibleForTesting
  String? getVerificationCode(String email) => _verificationCodes[email.trim().toLowerCase()];
}


