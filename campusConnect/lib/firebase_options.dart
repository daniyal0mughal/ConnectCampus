import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Public client configuration, not an administrator credential.
FirebaseOptions get campusFirebaseOptions {
  if (kIsWeb) return _web;
  if (defaultTargetPlatform == TargetPlatform.android) return _android;
  throw UnsupportedError('Firebase is configured for web and Android.');
}

const _android = FirebaseOptions(
  apiKey: 'AIzaSyAQ0k4dumCx34lqR3FduD_sHVc0RLt44gM',
  appId: '1:193428490252:android:ef8a6015b0d2bf6b158629',
  messagingSenderId: '193428490252',
  projectId: 'campusconnect-9c792',
);

const _web = FirebaseOptions(
  apiKey: 'AIzaSyDKEyg-9yQPkfKkUTySG6v-2c-2IEUVyDE',
  appId: '1:193428490252:web:fe8fcc05fb0df245158629',
  messagingSenderId: '193428490252',
  projectId: 'campusconnect-9c792',
  authDomain: 'campusconnect-9c792.firebaseapp.com',
);
