// File generated for Online Pharma Customer app.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_2NF_srV3tDX-Zokynvszjjmq8b7EPvU',
    appId: '1:584383465211:android:50794dab5a5c9f9e0dd25e',
    messagingSenderId: '584383465211',
    projectId: 'online-pharma-a0170',
    storageBucket: 'online-pharma-a0170.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_2NF_srV3tDX-Zokynvszjjmq8b7EPvU',
    appId: '1:584383465211:android:50794dab5a5c9f9e0dd25e',
    messagingSenderId: '584383465211',
    projectId: 'online-pharma-a0170',
    storageBucket: 'online-pharma-a0170.firebasestorage.app',
    iosBundleId: 'com.pt.onlinepharma',
  );
}
