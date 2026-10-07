import 'package:flutter/material.dart';

import '../services/learning_analytics_service.dart';
import '../services/techstep_auth_database.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthGate extends StatefulWidget {
  final Widget Function(Map<String, dynamic> user)
      authenticatedHomeBuilder;

  const AuthGate({
    super.key,
    required this.authenticatedHomeBuilder,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authDatabase = TechStepAuthDatabase.instance;

  bool _isLoggedIn = false;
  bool _showRegister = false;
  Map<String, dynamic>? _currentUser;

  Future<bool> _handleLogin(
    String username,
    String password,
  ) async {
    final success = await _authDatabase.loginUser(
      nis: username,
      password: password,
    );

    if (!success) {
      return false;
    }

    _currentUser = await _authDatabase.getUserByNis(username);

    if (_currentUser != null) {
      await LearningAnalyticsService.instance.refresh();
    }

    return _currentUser != null;
  }

  Future<bool> _handleRegister({
    required String name,
    required String nis,
    required String className,
    required String password,
  }) {
    return _authDatabase.registerUser(
      name: name,
      nis: nis,
      className: className,
      password: password,
    );
  }

  void _openRegister() {
    setState(() {
      _showRegister = true;
    });
  }

  void _openLogin() {
    setState(() {
      _showRegister = false;
    });
  }

  void _loginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn && _currentUser != null) {
      return widget.authenticatedHomeBuilder(
        _currentUser!,
      );
    }

    if (_showRegister) {
      return RegisterScreen(
        onRegister: _handleRegister,
        onBackToLogin: _openLogin,
      );
    }

    return LoginScreen(
      onLogin: (username, password) async {
        final success = await _handleLogin(
          username,
          password,
        );

        if (success) {
          _loginSuccess();
        }

        return success;
      },
      onRegister: _openRegister,
    );
  }
}
