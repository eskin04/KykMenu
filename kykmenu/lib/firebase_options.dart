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
    apiKey: 'AIzaSyDxmC264oT4HHxQP6Gqa613UoAqi3wdpec',
    appId: '1:996345658777:web:05fa44a39ecbacd6b0a708',
    messagingSenderId: '996345658777',
    projectId: 'kykmenu-7fe1e',
    authDomain: 'kykmenu-7fe1e.firebaseapp.com',
    storageBucket: 'kykmenu-7fe1e.firebasestorage.app',
    measurementId: 'G-16HEDXWDT3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAfmqd8txJfll6kKVNupvJU1PHFWBZAGEo',
    appId: '1:996345658777:android:88ac0f128ff668a0b0a708',
    messagingSenderId: '996345658777',
    projectId: 'kykmenu-7fe1e',
    storageBucket: 'kykmenu-7fe1e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDWqnZGHQFUFNWB78gc7rXYSQRyUgA9gLY',
    appId: '1:996345658777:ios:4630d8537d719f1eb0a708',
    messagingSenderId: '996345658777',
    projectId: 'kykmenu-7fe1e',
    storageBucket: 'kykmenu-7fe1e.firebasestorage.app',
    iosBundleId: 'com.example.kykmenu',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDWqnZGHQFUFNWB78gc7rXYSQRyUgA9gLY',
    appId: '1:996345658777:ios:4630d8537d719f1eb0a708',
    messagingSenderId: '996345658777',
    projectId: 'kykmenu-7fe1e',
    storageBucket: 'kykmenu-7fe1e.firebasestorage.app',
    iosBundleId: 'com.example.kykmenu',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDxmC264oT4HHxQP6Gqa613UoAqi3wdpec',
    appId: '1:996345658777:web:97394b181eb6bb73b0a708',
    messagingSenderId: '996345658777',
    projectId: 'kykmenu-7fe1e',
    authDomain: 'kykmenu-7fe1e.firebaseapp.com',
    storageBucket: 'kykmenu-7fe1e.firebasestorage.app',
    measurementId: 'G-Q7Y8CPWM8Q',
  );
}
