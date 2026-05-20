import 'package:flutter/material.dart';

import 'app.dart';
import 'bootstrap/firebase_bootstrap.dart';

/// Entry point of the ChefInPocket application.
/// This is where the app starts running.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrapResult = await FirebaseBootstrap.initialize();
  runApp(ChefInPocketApp(bootstrapResult: bootstrapResult));
}
