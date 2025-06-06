import 'package:attendee/auth/supabase_auth.dart';
import 'package:attendee/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import 'admin_dashboard.dart';
import 'dashboard.dart';


class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  SplashscreenState createState() => SplashscreenState();
}

class SplashscreenState extends State<Splashscreen> {

  String userDesignation="";
  Future<bool> fetchUserDesignation(BuildContext context) async {
    await Provider.of<DatabaseHelperProvider>(
      context,
      listen: false,
    ).fetchUserProfile();
    if (!context.mounted) return false;
    Map<String, dynamic>? profile =
        Provider.of<DatabaseHelperProvider>(context, listen: false).profile;

    if (profile != null &&  profile.isNotEmpty) {
      final designation = profile['designation'].toString().trim();
      if (designation == "" || designation.isEmpty) {
        return false;
      }
      userDesignation=designation;
      return true;
    }
    return true;
  }



  @override
  void initState() {
    super.initState();
    _setSystemUI();
    _navigateToLoginPage();

  }

  // Set The color Of the System Ui Time and Clock to be visible while splash screen occurs
  void _setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  // Navigating to Login Page
  void _navigateToLoginPage() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    
    bool isDesignationFound=await fetchUserDesignation(context);

    final bool isLoggedIn = OauthHelper.isUserLoggedIn();

    late final Widget destination;

    if (!isLoggedIn) {
      destination = const LoginPage();
    } else if (isDesignationFound && userDesignation == "Admin") {
      destination = AdminDashboard(user: OauthHelper.currentUser());
    } else {
      destination = HomePage(user: OauthHelper.currentUser());
    }

    if(!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(
              Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.bounceIn)),
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = MediaQuery.of(context).size.width * 0.25;

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to extend behind AppBar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Icon(Icons.fingerprint, size: iconSize, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Attendee',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}