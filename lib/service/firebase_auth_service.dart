// lib/services/firebase_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Optionally store credentials for biometric login
      await _secureStorage.write(key: 'email', value: email);
      await _secureStorage.write(key: 'password', value: password);

      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getUserRole(String uid) async {
    try {
      final DataSnapshot snapshot = await _db.child('users/$uid/role').get();
      return snapshot.value as String?;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _secureStorage.deleteAll();
  }

  Future<Map<String, String>?> getStoredCredentials() async {
    final email = await _secureStorage.read(key: 'email');
    final password = await _secureStorage.read(key: 'password');
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }
}
