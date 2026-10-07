import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final Future<bool> Function({
    required String name,
    required String nis,
    required String className,
    required String password,
  })? onRegister;

  final VoidCallback? onBackToLogin;

  const RegisterScreen({
    super.key,
    this.onRegister,
    this.onBackToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nisController = TextEditingController();
  final _classController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _nisController.dispose();
    _classController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.onRegister == null) {
      setState(() {
        _errorMessage = 'Fitur pendaftaran belum terhubung ke database.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onRegister!(
        name: _nameController.text.trim(),
        nis: _nisController.text.trim(),
        className: _classController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (!success) {
        setState(() {
          _errorMessage = 'NIS/Username sudah terdaftar.';
          _isLoading = false;
        });
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil. Silakan masuk.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (widget.onBackToLogin != null) {
        widget.onBackToLogin!();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Pendaftaran gagal. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF6C4AB6),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo / nama aplikasi
                    Container(
                      width: 82,
                      height: 82,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C4AB6).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 42,
                        color: Color(0xFF6C4AB6),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'TechStep',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C4AB6),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      'Buat akun untuk mulai belajar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 28),

                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        label: 'Nama Lengkap',
                        icon: Icons.person_outline_rounded,
                      ),
                      validator: (value) => _required(
                        value,
                        'Nama lengkap',
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _nisController,
                      keyboardType: TextInputType.text,
                      decoration: _inputDecoration(
                        label: 'NIS / Username',
                        icon: Icons.badge_outlined,
                      ),
                      validator: (value) {
                        final error = _required(value, 'NIS/Username');
                        if (error != null) return error;

                        if (value!.trim().length < 3) {
                          return 'NIS/Username minimal 3 karakter';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _classController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: _inputDecoration(
                        label: 'Kelas',
                        icon: Icons.class_outlined,
                        // Contoh: X TJKT 1
                      ),
                      validator: (value) => _required(
                        value,
                        'Kelas',
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: _inputDecoration(
                        label: 'Password',
                        icon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final error = _required(value, 'Password');
                        if (error != null) return error;

                        if (value!.length < 6) {
                          return 'Password minimal 6 karakter';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: _inputDecoration(
                        label: 'Konfirmasi Password',
                        icon: Icons.lock_reset_outlined,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final error = _required(
                          value,
                          'Konfirmasi password',
                        );
                        if (error != null) return error;

                        if (value != _passwordController.text) {
                          return 'Konfirmasi password tidak sama';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.shade200,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C4AB6),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              const Color(0xFF6C4AB6).withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onBackToLogin,
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C4AB6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
