import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

/// UC-3: Password Recovery (Forgot Password) screen.
///
/// Allows users to reset their password by entering their registered email,
/// receiving a verification code, and setting a new password.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();

  // Step 1 – email entry
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // Step 2 – code verification
  final _codeFormKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  // Step 3 – new password
  final _passwordFormKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  int _step = 1; // 1 = email, 2 = code, 3 = new password

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final result = _authService.requestPasswordReset(email: _emailController.text);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      setState(() => _step = 2);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? ''), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Error.'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _verifyCode() async {
    if (!_codeFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final result = _authService.verifyResetCode(
      email: _emailController.text,
      code: _codeController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      setState(() => _step = 3);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Invalid code.'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final result = _authService.resetPassword(
      email: _emailController.text,
      code: _codeController.text,
      newPassword: _newPasswordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Password reset.'), backgroundColor: Colors.green),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Error.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 1:
        return _buildEmailStep();
      case 2:
        return _buildCodeStep();
      case 3:
        return _buildNewPasswordStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmailStep() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'Reset your password',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your registered email address and we will send you a verification code.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            key: const Key('resetEmailField'),
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your email address.';
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('sendCodeButton'),
            onPressed: _isLoading ? null : _requestCode,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Send Verification Code', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeStep() {
    return Form(
      key: _codeFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'Enter verification code',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'A 6-digit code was sent to ${_emailController.text}.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            key: const Key('codeField'),
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Verification Code',
              prefixIcon: Icon(Icons.pin_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter the verification code.';
              if (value.trim().length != 6) return 'Code must be 6 digits.';
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('verifyCodeButton'),
            onPressed: _isLoading ? null : _verifyCode,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Verify Code', style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            key: const Key('resendCodeButton'),
            onPressed: _isLoading ? null : () => setState(() => _step = 1),
            child: const Text('Resend Code'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewPasswordStep() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'Create new password',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            key: const Key('newPasswordField'),
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              labelText: 'New Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscureNewPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a new password.';
              if (value.length < 8) return 'Password must be at least 8 characters.';
              if (!value.contains(RegExp(r'[A-Z]'))) return 'Include at least one uppercase letter.';
              if (!value.contains(RegExp(r'[a-z]'))) return 'Include at least one lowercase letter.';
              if (!value.contains(RegExp(r'[0-9]'))) return 'Include at least one digit.';
              if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                return 'Include at least one special character.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('confirmNewPasswordField'),
            controller: _confirmNewPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            validator: (value) {
              if (value != _newPasswordController.text) return 'Passwords do not match.';
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('resetPasswordButton'),
            onPressed: _isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Reset Password', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
