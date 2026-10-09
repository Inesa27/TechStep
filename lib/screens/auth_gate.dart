import 'package:flutter/material.dart';

import '../services/learning_analytics_service.dart';
import '../services/techstep_auth_database.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthGate extends StatefulWidget {
  final Widget Function(Map<String, dynamic> user, VoidCallback onLogout)
  authenticatedHomeBuilder;

  const AuthGate({super.key, required this.authenticatedHomeBuilder});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authDatabase = TechStepAuthDatabase.instance;

  bool _isLoggedIn = false;
  bool _showRegister = false;
  Map<String, dynamic>? _currentUser;

  Future<bool> _handleLogin(String username, String password) async {
    final success = await _authDatabase.loginUser(
      nis: username,
      password: password,
    );

    if (!success) {
      return false;
    }

    final user = await _authDatabase.getUserByNis(username);
    if (user == null) {
      return false;
    }

    final userId = int.tryParse(user['id'].toString());
    if (userId == null || userId <= 0) {
      return false;
    }

    await LearningAnalyticsService.instance.setCurrentStudent(
      id: userId,
      name: user['name']?.toString() ?? 'Siswa TechStep',
      className: user['class_name']?.toString() ?? 'X TJKT',
    );

    _currentUser = user;
    return true;
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

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _showRegister = false;
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn && _currentUser != null) {
      return widget.authenticatedHomeBuilder(_currentUser!, _handleLogout);
    }

    if (_showRegister) {
      return RegisterScreen(
        onRegister: _handleRegister,
        onBackToLogin: _openLogin,
      );
    }

    return LoginScreen(
      onLogin: (username, password) async {
        final success = await _handleLogin(username, password);

        if (success) {
          _loginSuccess();
        }

        return success;
      },
      onRegister: _openRegister,
    );
  }
}
