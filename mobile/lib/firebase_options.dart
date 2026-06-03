import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBeJQy9ttzMkxlp4W3a8VaMv2CQsBa5HMI',
    appId: '1:1003285431197:android:b7903b7b3abc48e4676574',
    messagingSenderId: '1003285431197',
    projectId: 'growwise-ffa08',
    storageBucket: 'growwise-ffa08.firebasestorage.app',
  );

  // TODO: Điền web config từ Firebase Console → Project Settings → Your apps → Web app
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_WEB_API_KEY',
    appId: 'REPLACE_WITH_WEB_APP_ID',
    messagingSenderId: '1003285431197',
    projectId: 'growwise-ffa08',
    authDomain: 'growwise-ffa08.firebaseapp.com',
    storageBucket: 'growwise-ffa08.firebasestorage.app',
  );
}
