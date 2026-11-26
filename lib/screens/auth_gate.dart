import 'dart:async';

import 'package:flutter/material.dart';

import '../services/learning_analytics_service.dart';
import '../services/techstep_auth_database.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'welcome_screen.dart';

class AuthGate extends StatefulWidget {
  final Widget Function(
    Map<String, dynamic> user,
    VoidCallback onLogout, {
    required bool showOnboarding,
  })
  authenticatedHomeBuilder;

  const AuthGate({super.key, required this.authenticatedHomeBuilder});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authDatabase = TechStepAuthDatabase.instance;

  bool _isLoggedIn = false;
  bool _isRestoringSession = true;
  bool _showWelcome = true;
  bool _showRegister = false;
  bool _showOnboarding = false;
  String? _sessionRestoreError;
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    unawaited(_restoreSession());
  }

  Future<void> _restoreSession() async {
    setState(() {
      _isRestoringSession = true;
      _sessionRestoreError = null;
    });

    try {
      final nis = await _authDatabase.getActiveSessionNis();
      if (nis != null && nis.isNotEmpty) {
        final user = await _authDatabase.getUserByNis(nis);
        final userId = int.tryParse(user?['id']?.toString() ?? '');

        if (user == null || userId == null || userId <= 0) {
          await _authDatabase.clearActiveSession();
        } else {
          await LearningAnalyticsService.instance.setCurrentStudent(
            id: userId,
            name: user['name']?.toString() ?? 'Siswa TechStep',
            className: user['class_name']?.toString() ?? 'X TJKT',
          );

          if (!mounted) return;
          setState(() {
            _currentUser = user;
            _isLoggedIn = true;
            _showWelcome = false;
            _showOnboarding = false;
            _isRestoringSession = false;
          });
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        _isRestoringSession = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isRestoringSession = false;
        _sessionRestoreError = error.toString();
      });
    }
  }

  Future<bool> _handleLogin(String nis, String password) async {
    final success = await _authDatabase.loginUser(nis: nis, password: password);

    if (!success) {
      return false;
    }

    final user = await _authDatabase.getUserByNis(nis);
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
    await _authDatabase.saveActiveSessionNis(nis);

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
      _showWelcome = false;
      _showRegister = true;
    });
  }

  void _openLogin() {
    setState(() {
      _showWelcome = false;
      _showRegister = false;
    });
  }

  void _loginSuccess() {
    setState(() {
      _isLoggedIn = true;
      _showWelcome = false;
      _showOnboarding = true;
    });
  }

  Future<void> _handleLogout() async {
    try {
      await _authDatabase.clearActiveSession();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sesi belum berhasil dihapus: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoggedIn = false;
      _isRestoringSession = false;
      _showWelcome = true;
      _showRegister = false;
      _showOnboarding = false;
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isRestoringSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_sessionRestoreError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 42,
                    color: Color(0xFFD93649),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Sesi belum dapat dipulihkan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_sessionRestoreError!, textAlign: TextAlign.center),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () => unawaited(_restoreSession()),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_isLoggedIn && _currentUser != null) {
      return widget.authenticatedHomeBuilder(
        _currentUser!,
        () => unawaited(_handleLogout()),
        showOnboarding: _showOnboarding,
      );
    }

    if (_showRegister) {
      return RegisterScreen(
        onRegister: _handleRegister,
        onBackToLogin: _openLogin,
      );
    }

    if (_showWelcome) {
      return WelcomeScreen(onStart: _openLogin);
    }

    return LoginScreen(
      onLogin: (nis, password) async {
        final success = await _handleLogin(nis, password);

        if (success) {
          _loginSuccess();
        }

        return success;
      },
      onRegister: _openRegister,
    );
  }
}
