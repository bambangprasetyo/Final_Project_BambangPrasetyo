import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h8_fli_biometric_starter/presentation/managers/biometric_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    context.read<BiometricBloc>().add(BiometricCheckAvailability());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocConsumer<BiometricBloc, BiometricState>(
        listener: (context, state) {
          if (state is BiometricAuthInSuccess) {
            Navigator.of(context).pushNamed('/home');
          }
          if (state is BiometricAuthInFail) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Authentication failed')),
            );
          }
        },
        builder: (context, state) {
          String statusMessage = switch (state) {
            BiometricInitial() => 'Silakan autentikasi',
            BiometricAuthInProgress() => 'Sedang memverifikasi...',
            BiometricAuthInSuccess() => 'Autentikasi berhasil!',
            BiometricAuthInFail() => state.message ?? 'Autentikasi gagal',
          };

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      statusMessage,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Masukkan password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.fingerprint),
                          onPressed: () {
                            context.read<BiometricBloc>().add(
                              BiometricAuthenticate(),
                            );
                          },
                        ),
                      ),
                      onSubmitted: (value) {
                        context.read<BiometricBloc>().add(
                          BiometricAuthenticate(password: value),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Autentikasi'),
                      onPressed: () {
                        context.read<BiometricBloc>().add(
                          BiometricAuthenticate(),
                        );
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
