import 'package:attendee/pages/dashboard.dart';
import 'package:attendee/pages/login_page.dart';
import 'package:attendee/pages/registration_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthHelper {

  /// Sign-up function to register a new user
  Future<void> signUp(String email, String password, BuildContext context) async {

    // Validate if email or password is empty
    if (email.isEmpty || password.isEmpty) {
      // Navigate back to registration page with an error message
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RegistrationPage(errorMessage: "Please enter email and password"),
        ),
      );
      return;
    }

    try {
      // Create user with Firebase Authentication
      UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, password: password
      );

      // Navigate to HomePage after successful signup
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(usercred: userCred),
        ),
            (route) => false, // Removes all previous routes from navigation stack
      );
    }
    on FirebaseAuthException catch (error) {
      // Convert Firebase error code to a user-friendly message
      String errorMsg = getFirebaseErrorMessage(error.code);

      // Navigate back to registration page and display the error message
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RegistrationPage(errorMessage: errorMsg),
        ),
      );
    }
  }

  /// Login function for existing users
  Future<void> logIn(BuildContext context, String email, String password) async {

    // Validate if email or password is empty
    if (email.isEmpty || password.isEmpty) {
      // Navigate back to login page with an error message
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(errorMessage: "Please enter email and password"),
        ),
      );
      return;
    }

    try {
      // Sign in user using Firebase Authentication
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Navigate to HomePage after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(usercred: userCred),
        ),
      );
    }
    on FirebaseAuthException catch (err) {
      // Convert Firebase error code to a user-friendly message
      String errorMsg = getFirebaseErrorMessage(err.code);

      // Show error using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Function to map Firebase error codes to user-friendly messages
  String getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'Invalid email format. Please enter a valid email.';
      case 'user-not-found':
        return 'No user found with this email. Please check or sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
