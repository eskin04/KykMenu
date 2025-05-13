import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kykmenu/firebase_options.dart';

class FireBaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  //function to initialize notifications
  Future<void> initNotifications() async {
    await Firebase.initializeApp(
      name: "kykmenu",
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print("FCM Token: $fCMToken");
  }
}
