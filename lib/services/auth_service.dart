import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Only ALU email addresses are allowed to use the app.
bool isAluEmail(String email) {
  final e = email.trim().toLowerCase();
  return e.endsWith('@alustudent.com') || e.endsWith('@alueducation.com');
}

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get authChanges => _auth.userChanges();

  Future<void> register(String name, String email, String password) async {
    if (!isAluEmail(email)) {
      throw FirebaseAuthException(
          code: 'invalid-email', message: 'Please use your ALU email address.');
    }
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = cred.user!;
    await user.updateDisplayName(name);
    // Every new account is a student. Staff role is granted in Firestore.
    await _db.collection('users').doc(user.uid).set({
      'name': name,
      'email': email,
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await user.sendEmailVerification();
  }

  Future<void> login(String email, String password) async {
    if (!isAluEmail(email)) {
      throw FirebaseAuthException(
          code: 'invalid-email', message: 'Please use your ALU email address.');
    }
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() => _auth.signOut();

  Future<void> resendVerification() async =>
      _auth.currentUser?.sendEmailVerification();

  /// Reloads the user so `emailVerified` is up to date and refreshes the token
  /// (Firestore rules read `email_verified` from the token).
  Future<User?> reloadUser() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    await u.reload();
    await _auth.currentUser?.getIdToken(true);
    return _auth.currentUser;
  }

  Future<String> fetchRole(String uid) async {
    try {
      final d = await _db.collection('users').doc(uid).get();
      return (d.data()?['role'] as String?) ?? 'student';
    } catch (_) {
      return 'student';
    }
  }
}
