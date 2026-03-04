import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movemate/main.dart';
import 'package:movemate/screens/register_screen.dart';
import 'package:movemate/screens/login_screen.dart';
import 'package:movemate/screens/forgot_password_screen.dart';

void main() {
  testWidgets('MoveMate app loads register screen by default', (WidgetTester tester) async {
    await tester.pumpWidget(const MoveMateApp());
    expect(find.text('Create Account'), findsOneWidget);
  });

  group('RegisterScreen', () {
    testWidgets('shows all required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RegisterScreen()),
      );

      expect(find.byKey(const Key('fullNameField')), findsOneWidget);
      expect(find.byKey(const Key('emailField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('confirmPasswordField')), findsOneWidget);
      expect(find.byKey(const Key('signUpButton')), findsOneWidget);
    });

    testWidgets('shows validation errors when form is submitted empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RegisterScreen()),
      );

      await tester.tap(find.byKey(const Key('signUpButton')));
      await tester.pump();

      expect(find.text('Please enter your full name.'), findsOneWidget);
    });

    testWidgets('navigate to login screen via link', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
          routes: {'/login': (ctx) => const LoginScreen()},
        ),
      );

      await tester.tap(find.byKey(const Key('goToLoginButton')));
      await tester.pumpAndSettle();

      expect(find.text('Log In'), findsWidgets);
    });
  });

  group('LoginScreen', () {
    testWidgets('shows email, password fields and login button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      expect(find.byKey(const Key('emailField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
      expect(find.byKey(const Key('forgotPasswordButton')), findsOneWidget);
    });

    testWidgets('shows validation errors when submitted empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();

      expect(find.text('Please enter your email address.'), findsOneWidget);
    });

    testWidgets('navigate to forgot password screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      await tester.tap(find.byKey(const Key('forgotPasswordButton')));
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password'), findsWidgets);
    });
  });

  group('ForgotPasswordScreen', () {
    testWidgets('shows email field and send code button on step 1', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ForgotPasswordScreen()),
      );

      expect(find.byKey(const Key('resetEmailField')), findsOneWidget);
      expect(find.byKey(const Key('sendCodeButton')), findsOneWidget);
    });

    testWidgets('shows validation error when email is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ForgotPasswordScreen()),
      );

      await tester.tap(find.byKey(const Key('sendCodeButton')));
      await tester.pump();

      expect(find.text('Please enter your email address.'), findsOneWidget);
    });
  });
}
