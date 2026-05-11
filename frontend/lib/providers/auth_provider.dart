import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    final currentUser = FirebaseAuth.instance.currentUser;
    _user = currentUser;
    _status = currentUser == null
        ? AuthStatus.unknown
        : AuthStatus.authenticated;

    _subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      _status = user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  StreamSubscription<User?>? _subscription;
  User? _user;
  AuthStatus _status = AuthStatus.unknown;
  String? _error;

  User? get user => _user;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  String get displayName =>
      _user?.displayName ?? _user?.email?.split('@').first ?? 'Chef';

  String get email => _user?.email ?? '';

  Future<bool> login(String email, String password) async {
    _error = null;
    notifyListeners();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapError(e.code);
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Login failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    _error = null;
    notifyListeners();
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(fullName.trim());
      await FirestoreService.instance.saveUserProfile(
        uid: cred.user!.uid,
        fullName: fullName.trim(),
        email: email.trim().toLowerCase(),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapError(e.code);
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Registration failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
