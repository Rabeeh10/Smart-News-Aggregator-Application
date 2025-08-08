import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Register a new user
  Future<UserCredential> registerWithEmailPassword(String email, String password) async {
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign in an existing user
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
