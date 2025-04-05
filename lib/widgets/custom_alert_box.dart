import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/dashboard.dart';


class CustomAlertBox{

  void showCustomAnimatedAlert({required BuildContext context, required String title,required String label, required User? user}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      barrierLabel: "Custom Alert", // screen reader label reads
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        final size = MediaQuery.of(context).size;
        final bool isSmallScreen = size.width < 400;

        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0x4D000000)
                    : Color(0x66FFFFFF),
              ),
            ),


            // Center Dialog Box
            Center(
              child: Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  width: size.width * 0.8,
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/thanks.png',
                          height: size.height * 0.2,
                          width: size.width * 0.5,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 20),
                        Text( title,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: isSmallScreen ? 20 : 24, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        SizedBox(height: 10),
                        Text(label,
                          style: TextStyle( fontSize: isSmallScreen ? 14 : 18,
                          color:  Theme.of(context).brightness == Brightness.dark
                                         ? const Color(0xFFFFFFFF)
                                         : const Color(0xFF4A4A4E),
                    
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(user: user!),
                                ),
                                    (route) => false, // Removes all previous routes from navigation stack
                              );

                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Back to Home', style: TextStyle(color: Colors.white,   fontSize: isSmallScreen ? 14 : 16, )),
                        ),
                      ],
                    ),
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

