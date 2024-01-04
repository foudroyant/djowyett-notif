import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyBA8lgGtRSa88KEc1X_0BhHm0Xfeh4eOfg",
            authDomain: "djowyett.firebaseapp.com",
            projectId: "djowyett",
            storageBucket: "djowyett.appspot.com",
            messagingSenderId: "478289729883",
            appId: "1:478289729883:web:80bbd6bde0d61f00b2627e"));
  } else {
    await Firebase.initializeApp();
  }
}
