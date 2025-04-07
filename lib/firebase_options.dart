// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDPWDZszhIHN3jgcVRqsN6WzJp-BC1YzXs',
    appId: '1:745059065733:web:0073cb3ee3293d41fb6eec',
    messagingSenderId: '745059065733',
    projectId: 'kifg-legal',
    authDomain: 'kifg-legal.firebaseapp.com',
    storageBucket: 'kifg-legal.firebasestorage.app',
    measurementId: 'G-8LR6BHS0VJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyACR-NRSV0k8B3Br-pZhxFdTDTrMYd5Oyw',
    appId: '1:745059065733:android:3d9e84bfd80ba87ffb6eec',
    messagingSenderId: '745059065733',
    projectId: 'kifg-legal',
    storageBucket: 'kifg-legal.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAemdZqUP-wvH4rOtbRL2T8yjlEYrLVXmo',
    appId: '1:745059065733:ios:b32f35b0b04fb834fb6eec',
    messagingSenderId: '745059065733',
    projectId: 'kifg-legal',
    storageBucket: 'kifg-legal.firebasestorage.app',
    iosBundleId: 'com.example.kifg',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAemdZqUP-wvH4rOtbRL2T8yjlEYrLVXmo',
    appId: '1:745059065733:ios:b32f35b0b04fb834fb6eec',
    messagingSenderId: '745059065733',
    projectId: 'kifg-legal',
    storageBucket: 'kifg-legal.firebasestorage.app',
    iosBundleId: 'com.example.kifg',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDPWDZszhIHN3jgcVRqsN6WzJp-BC1YzXs',
    appId: '1:745059065733:web:50caa066792ec35dfb6eec',
    messagingSenderId: '745059065733',
    projectId: 'kifg-legal',
    authDomain: 'kifg-legal.firebaseapp.com',
    storageBucket: 'kifg-legal.firebasestorage.app',
    measurementId: 'G-Y9LMVN8QLZ',
  );
}
