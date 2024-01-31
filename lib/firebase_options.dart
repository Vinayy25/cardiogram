// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBz1rmxDzrvXPBcOaIPwujizZ1Fz3yALFI',
    appId: '1:17965689242:web:8331244815822013c2b223',
    messagingSenderId: '17965689242',
    projectId: 'cardiogram-proj',
    authDomain: 'cardiogram-proj.firebaseapp.com',
    databaseURL: 'https://cardiogram-proj-default-rtdb.firebaseio.com',
    storageBucket: 'cardiogram-proj.appspot.com',
    measurementId: 'G-Z35GZ9FGL5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBXW4jD4Mg7BBoEmTdrgSmjwLIFPtuWohU',
    appId: '1:17965689242:android:00665ba14e668677c2b223',
    messagingSenderId: '17965689242',
    projectId: 'cardiogram-proj',
    databaseURL: 'https://cardiogram-proj-default-rtdb.firebaseio.com',
    storageBucket: 'cardiogram-proj.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB2o0qvUNxXgHs_hX7CuyQDS94amSCxbbA',
    appId: '1:17965689242:ios:779a83412ddfcbc5c2b223',
    messagingSenderId: '17965689242',
    projectId: 'cardiogram-proj',
    databaseURL: 'https://cardiogram-proj-default-rtdb.firebaseio.com',
    storageBucket: 'cardiogram-proj.appspot.com',
    iosBundleId: 'com.example.cardiogram',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB2o0qvUNxXgHs_hX7CuyQDS94amSCxbbA',
    appId: '1:17965689242:ios:2d17696fd2458be5c2b223',
    messagingSenderId: '17965689242',
    projectId: 'cardiogram-proj',
    databaseURL: 'https://cardiogram-proj-default-rtdb.firebaseio.com',
    storageBucket: 'cardiogram-proj.appspot.com',
    iosBundleId: 'com.example.cardiogram.RunnerTests',
  );
}