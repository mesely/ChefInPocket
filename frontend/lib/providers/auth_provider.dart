import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _subscription = ApiService.instance.authStateChanges().listen((user) {
      _user = user;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();

      if (user != null) {
        _syncSignedInUser();
      }
    });
  }

  StreamSubscription<User?>? _subscription;
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.instance.login(email, password);
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String gender,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.instance.register(
        fullName: fullName,
        email: email,
        password: password,
        gender: gender,
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await ApiService.instance.logout();
  }

  Future<void> _syncSignedInUser() async {
    try {
      await ApiService.instance.ensureCurrentUserProfile();
      await ApiService.instance.ensureSeedData();
      _errorMessage = null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    }

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
