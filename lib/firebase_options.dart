// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, import_of_legacy_library_into_null_safe
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
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCcXMgDtTsZH5Y83ShPN2CzOHS8UA7m9cU',
    appId: '1:228130743588:web:944bb784775ef1c727ffb1',
    messagingSenderId: '228130743588',
    projectId: 'music-pool-app-50127',
    authDomain: 'music-pool-app-50127.firebaseapp.com',
    databaseURL:
        'https://music-pool-app-50127-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'music-pool-app-50127.appspot.com',
    measurementId: 'G-JRG2PQP067',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBaGBPT_J2MuhsYM1lVXMhHU1I5DtY11W8',
    appId: '1:228130743588:android:19362cb3eb0dd7ef27ffb1',
    messagingSenderId: '228130743588',
    projectId: 'music-pool-app-50127',
    databaseURL:
        'https://music-pool-app-50127-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'music-pool-app-50127.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC4ynUW3xC6Gq9xCZeDow6z4rK3tf0suls',
    appId: '1:228130743588:ios:7c773f85d432ddb927ffb1',
    messagingSenderId: '228130743588',
    projectId: 'music-pool-app-50127',
    databaseURL:
        'https://music-pool-app-50127-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'music-pool-app-50127.appspot.com',
    androidClientId:
        '228130743588-1nk9hk6gv9he31b8ao8l8gs0ct5ndahb.apps.googleusercontent.com',
    iosClientId:
        '228130743588-p80be426996gviaj1t1qq5mmje12cu9j.apps.googleusercontent.com',
    iosBundleId: 'com.CrutoiAlexandru.musicPoolApp',
  );
}