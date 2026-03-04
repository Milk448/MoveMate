import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const MoveMateApp());
}

class MoveMateApp extends StatelessWidget {
  const MoveMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoveMate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/register',
      routes: {
        '/register': (_) => const RegisterScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomePage(),
      },
    );
  }
}

/// Placeholder home page displayed after successful login.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('MoveMate'),
      ),
      body: const Center(
        child: Text(
          'Welcome to MoveMate!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
