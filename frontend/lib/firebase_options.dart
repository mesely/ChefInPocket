import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return web;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDfSV8pfthXgxMzzKpIa9LwKmLbJc__Zf0',
    appId: '1:413835266030:ios:23368f1fd99d18b07370ff',
    messagingSenderId: '413835266030',
    projectId: 'chefinpocket',
    storageBucket: 'chefinpocket.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDfSV8pfthXgxMzzKpIa9LwKmLbJc__Zf0',
    appId: '1:413835266030:ios:23368f1fd99d18b07370ff',
    messagingSenderId: '413835266030',
    projectId: 'chefinpocket',
    authDomain: 'chefinpocket.firebaseapp.com',
    storageBucket: 'chefinpocket.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDfSV8pfthXgxMzzKpIa9LwKmLbJc__Zf0',
    appId: '1:413835266030:ios:23368f1fd99d18b07370ff',
    messagingSenderId: '413835266030',
    projectId: 'chefinpocket',
    storageBucket: 'chefinpocket.firebasestorage.app',
    iosBundleId: 'com.mesely.chefInPocketApp',
  );
}
