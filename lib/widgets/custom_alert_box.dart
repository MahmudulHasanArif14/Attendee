import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/dashboard.dart';


class CustomAlertBox{

  void showCustomAnimatedAlert({required BuildContext context, required String title,required String label, required UserCredential userCred}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      barrierLabel: "Custom Alert", // screen reader label reads
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0x80000000)
                    : Color(0x80FFFFFF),
              ),
            ),


            // Center Dialog Box
            Center(
              child: Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  width: 400,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/thanks.png',
                        height: 200,
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 20),
                      Text( title,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      SizedBox(height: 10),
                      Text(label,
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(usercred: userCred),
                              ),
                                  (route) => false, // Removes all previous routes from navigation stack
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Back to Home', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.7, end: 1.0).animate(anim1),
            child: child,
          ),
        );
      },
    );
  }







}

