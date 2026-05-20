import 'package:firebase_core/firebase_core.dart';

class FirebaseBootstrapResult {
  const FirebaseBootstrapResult._({required this.isReady, this.errorMessage});

  const FirebaseBootstrapResult.ready() : this._(isReady: true);

  const FirebaseBootstrapResult.failed(String message)
    : this._(isReady: false, errorMessage: message);

  final bool isReady;
  final String? errorMessage;
}

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static Future<FirebaseBootstrapResult> initialize() async {
    try {
      await Firebase.initializeApp();
      return const FirebaseBootstrapResult.ready();
    } catch (error) {
      return FirebaseBootstrapResult.failed(error.toString());
    }
  }
}
