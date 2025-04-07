import 'dart:async';
import 'package:attendee/auth/auth_helper.dart';
import 'package:attendee/pages/login_page.dart';
import 'package:attendee/widgets/custom_alert_box.dart';
import 'package:attendee/widgets/custom_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VerificationPage extends StatefulWidget {
  final User? user;
  final bool? isReset;
  final String? email;
  const VerificationPage({super.key,  this.user, this.isReset=false,this.email});
  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool isSend = false;
  late String lastName;
  late String email;
  Timer? _emailCheckTimer;
  int _resendTime = 0;
  Timer? _resendTimer;

  void resendLink() async {
    setState(() {
      isSend = true;
      _resendTime = 30;
    });

    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTime > 0) {
          _resendTime--;
        } else {
          timer.cancel();
        }
      });
    });

    try {
      await AuthHelper.sendVerificationEmail(context);
    } finally {
      setState(() {
        isSend = false;
      });
    }
  }

  void resetPassword() {
    setState(() {
      isSend = true;
      _resendTime = 30;
    });
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTime > 0) {
          _resendTime--;
        } else {
          timer.cancel();
        }
      });
    });


    try{
      final email = widget.email?.trim() ?? '';
      AuthHelper().resetPassword(context: context, email: email);

    }
    finally{
      setState(() {
        isSend = false;
      });
    }
  }




  @override
  void initState() {
    super.initState();
    var fullName = widget.user?.displayName?.split(' ') ?? [""];
    lastName = fullName.isNotEmpty ? fullName.last : "";
    email = widget.user?.email ?? "";

    if (!(widget.isReset!)) {
      _emailCheckTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
        if (FirebaseAuth.instance.currentUser != null) {
          await FirebaseAuth.instance.currentUser?.reload();
          var user = FirebaseAuth.instance.currentUser;
          if (user != null && user.emailVerified) {
            timer.cancel();
            if (mounted) {
              CustomAlertBox().showCustomAnimatedAlert(
                context: context,
                title: "🎉 Congratulations $lastName",
                label: "Your account is ready to use",
                user: user,
              );
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _emailCheckTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> openEmail() async {
    final Uri emailUri = Uri(scheme: 'mailto');
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          label: 'Could not launch email app',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isReset ?? false ? "Password Recovery" : "Email Verification",
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor:  Color(0xFF3C57A4),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 1,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3C57A4), // Blue
              Color(0xFF000000), // Black
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/mail.png",
                width: 150,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              Text(
                "Hi, $lastName",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Welcome to Attendee",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 12),
              widget.isReset ?? false
                  ? Text(
                "📩 Boom! Reset instructions are flying to your inbox now!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              )
                  : Text(
                "We have sent you an email verification link.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: widget.isReset ?? false
                    ? Text(
                  "Click on the Reset link sent to\n${widget.email ?? " "}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: Colors.white70,
                  ),
                )
                    : Text(
                  "Click on the verification link sent to\n$email",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: Colors.white70,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the email?",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  TextButton(
                    onPressed: widget.isReset ?? false
                        ? (_resendTime > 0 || isSend)
                        ? null
                        : resetPassword
                        : (_resendTime > 0 || isSend)
                        ? null
                        : resendLink,
                    child: isSend
                        ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(

                      ),
                    )
                        : Text(
                      _resendTime > 0
                          ? "Send Again ($_resendTime s)"
                          : "Send Again",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color:
                        _resendTime > 0 ? Colors.grey : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: openEmail,
                icon: Icon(Icons.email_outlined,color: Colors.white,size: 23,),
                label: Text("Open Email",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {

                  // Goes to Login Page
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                        (Route<dynamic> route) => false,
                  );

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: Text("🔑 Unlock Your Dashboard",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
