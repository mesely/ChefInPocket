import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions not configured for ${defaultTargetPlatform.name}.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDfSV8pfthXgxMzzKpIa9LwKmLbJc__Zf0',
    appId: '1:413835266030:ios:23368f1fd99d18b07370ff',
    messagingSenderId: '413835266030',
    projectId: 'chefinpocket',
    storageBucket: 'chefinpocket.firebasestorage.app',
    iosBundleId: 'com.mesely.chefInPocketApp',
  );
}
