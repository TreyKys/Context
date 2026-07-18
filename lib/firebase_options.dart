// ⚠️  PLACEHOLDER — NOT A REAL FIREBASE CONFIG.
//
// These values are dummies so the project compiles. The app will NOT connect to
// Firebase (and AI lookups will fail) until you replace this file with real
// values by running, from the project root:
//
//     dart pub global activate flutterfire_cli
//     flutterfire configure --project=<your-firebase-project-id>
//
// That command regenerates this file and installs android/app/google-services.json.
// Commit the regenerated file (Firebase config is not a secret). See PUBLISHING.md.
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'run the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'run the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  // TODO: Replace via `flutterfire configure`. These are placeholders.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME_ANDROID_API_KEY',
    appId: 'REPLACE_ME_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_ME_SENDER_ID',
    projectId: 'REPLACE_ME_PROJECT_ID',
    storageBucket: 'REPLACE_ME_PROJECT_ID.appspot.com',
  );
}
