import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService{

  static void init(){

    FirebaseMessaging.onMessage.listen((msg){
      print(msg.notification?.title);
      print(msg.notification?.body);
    });


  }


}