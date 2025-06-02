import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricDataSource {
  final LocalAuthentication localAuth;
  BiometricDataSource({required this.localAuth});

  Future<bool> checkAvailability() async {
    try {
      final isAvailable = await localAuth.canCheckBiometrics;
      final isSupported = await localAuth.isDeviceSupported();
      return isAvailable && isSupported;
    } catch (e) {
      log('Biometric Error: $e', name: 'checkAvailability');
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      log('Authentication error: $e', name: 'authenticate');
      return false;
    }
  }
}
