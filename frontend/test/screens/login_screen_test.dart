import 'package:chef_in_pocket_app/providers/auth_provider.dart';
import 'package:chef_in_pocket_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'LoginScreen validates input and submits credentials through AuthProvider',
    (tester) async {
      final fakeAuthProvider = FakeAuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: fakeAuthProvider,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      // The screen should render the two form fields required for login.
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);

      // First submit with empty fields to verify inline form validation.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(fakeAuthProvider.loginCallCount, 0);

      // Then enter valid input and submit again.
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'chef@student.edu',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'secure123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pumpAndSettle();

      // A successful submit should call the provider and show the success dialog.
      expect(fakeAuthProvider.loginCallCount, 1);
      expect(fakeAuthProvider.lastEmail, 'chef@student.edu');
      expect(fakeAuthProvider.lastPassword, 'secure123');
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(
        find.text('Login succeeded and Firebase connection is active.'),
        findsOneWidget,
      );
    },
  );
}

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  int loginCallCount = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  String? get errorMessage => null;

  @override
  bool get isAuthenticated => false;

  @override
  bool get isLoading => false;

  @override
  User? get user => null;

  @override
  void clearError() {}

  @override
  Future<void> login(String email, String password) async {
    loginCallCount += 1;
    lastEmail = email;
    lastPassword = password;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String gender,
  }) async {}
}
