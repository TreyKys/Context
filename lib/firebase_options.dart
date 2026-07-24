// Firebase configuration for project `com-context-dict-v1`.
// Values mirror android/app/google-services.json. Firebase config is not a
// secret (it's restricted by app package + App Check). If you add iOS or
// re-provision, regenerate with `flutterfire configure`.
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAzdakla_7_kO5DfEq_rAPcujnnv3m-b7s',
    appId: '1:321903242851:android:a253dde2e488eca38b5256',
    messagingSenderId: '321903242851',
    projectId: 'com-context-dict-v1',
    storageBucket: 'com-context-dict-v1.firebasestorage.app',
  );
}
