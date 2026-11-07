import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _svc = AuthService();

  User? user;
  String role = 'student';
  bool loading = true; // waiting for the first auth state
  bool busy = false; // a login/register call is running
  String? error;

  AuthProvider() {
    _svc.authChanges.listen((u) async {
      user = u;
      role = u == null ? 'student' : await _svc.fetchRole(u.uid);
      loading = false;
      notifyListeners();
    });
  }

  bool get isStaff => role == 'staff';
  bool get isVerified => user?.emailVerified ?? false;

  Future<bool> _run(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      error = e.message ?? e.code;
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) =>
      _run(() => _svc.login(email.trim(), password));

  Future<bool> register(String name, String email, String password) =>
      _run(() => _svc.register(name, email.trim(), password));

  Future<bool> resendVerification() => _run(_svc.resendVerification);

  Future<void> refreshUser() async {
    user = await _svc.reloadUser();
    if (user != null) role = await _svc.fetchRole(user!.uid);
    notifyListeners();
  }

  Future<void> logout() => _svc.logout();
}
