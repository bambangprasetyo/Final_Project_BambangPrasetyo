// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:h8_fli_biometric_starter/service/firebase_auth_service.dart';
import 'package:local_auth/local_auth.dart';
import '../data/datasources/biometric_data_source.dart';
import 'home_manager.dart';
import 'home_staff.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final BiometricDataSource _biometric = BiometricDataSource(
    localAuth: LocalAuthentication(),
  );

  bool _loading = false;
  String? _error;

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await _authService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      if (user != null) {
        final role = await _authService.getUserRole(user.uid);

        if (!context.mounted) return;

        if (role == 'manager') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeManager()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeStaff()),
          );
        }
      }
    } catch (e) {
      setState(() => _error = 'Login failed: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _biometricLogin() async {
    final available = await _biometric.checkAvailability();
    if (!available) return;

    final success = await _biometric.authenticate();
    if (!success) return;

    final creds = await _authService.getStoredCredentials();
    if (creds != null) {
      _emailController.text = creds['email']!;
      _passwordController.text = creds['password']!;
      _login();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            if (_loading)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton(onPressed: _login, child: const Text('Login')),
              TextButton(
                onPressed: _biometricLogin,
                child: const Text('Login with Biometric'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
