import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService{

  static void init(){

    FirebaseMessaging.onMessage.listen((msg){
      if (kDebugMode) {
        print(msg.notification?.title);
      }
      if (kDebugMode) {
        print(msg.notification?.body);
      }
    });


  }


}