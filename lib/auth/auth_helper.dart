import 'package:attendee/widgets/custom_alert_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../widgets/custom_snackbar.dart';

class AuthHelper {

  /// Sign-up function to register a new user
  Future<void> signUp({ required String email,required String password, required BuildContext context,required String name, String? fullPhoneNumber}) async {

    // Validate if email or password is empty
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      CustomSnackbar.show(
          context: context,
          label: "Field's Can't be Null"
      );
      return;
    }

    try {

      FirebaseAuth auth = FirebaseAuth.instance;

      // Create user with Firebase Authentication
      UserCredential userCred = await auth.createUserWithEmailAndPassword(
          email: email, password: password
      );

      List<String> nameParts = name.split(' ');
      String lastName = nameParts.isNotEmpty ? nameParts.last : "";





      // Set The name to the auth userInfo
      await userCred.user!.updateDisplayName(name);
      await userCred.user!.reload();

      // Go to home Page after success
      if (context.mounted) {
        //   Term Condition Page Here
        CustomAlertBox().showCustomAnimatedAlert(context: context,title: "🎉 Congratulations $lastName", label: "Your account is ready to use", userCred: userCred);

      }




    }
    on FirebaseAuthException catch (error) {
      // Convert Firebase error code to a user-friendly message
      String errorMsg = getFirebaseErrorMessage(error.code.toString());

      if(context.mounted){

        CustomSnackbar.show(
            context: context,
            label: errorMsg,
        );
      }


    }
  }





  static const int maxRetries = 3;
  static const int baseDelay = 2;

  Future<void> logIn(BuildContext context, String email, String password) async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {

        UserCredential userCred = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);


        retryCount = 0;


        String? fullName = userCred.user?.displayName;
        String lastName = "";

        if (fullName != null && fullName.isNotEmpty) {
          List<String> nameParts = fullName.split(' ');
          if (nameParts.isNotEmpty) {
            lastName = nameParts.last;
          }
        }


        if (context.mounted) {
          CustomAlertBox().showCustomAnimatedAlert(
            context: context,
            title: "Welcome back, $lastName",
            label: "The office missed you. Let’s get productive!",
            userCred: userCred,
          );
        }

        break;

      }
      on FirebaseAuthException catch (error) {

        String errorMsg = getFirebaseErrorMessage(error.code.toString());

        if(context.mounted){
          CustomSnackbar.show(
            context: context,
            label: errorMsg,
          );
        }





        retryCount++;

        if (retryCount < maxRetries) {
          int delay = baseDelay * (1 << retryCount);
          await Future.delayed(Duration(seconds: delay));
        } else {

          if(context.mounted){
            CustomSnackbar.show(
              context: context,
              label: "Too many failed attempts. Please try again later.",
            );
          }
          break;
        }
      }

    }
  }





  //Error Code Converter
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
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different credential. Please log in using that method.';
      case 'invalid-credential':
        return 'The credential is invalid. Please try again.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }



  Future<void> loginWithGoogle(BuildContext context) async {
    try {

      // Step 1: Start the Google sign-in process
      final googleUser = await GoogleSignIn().signIn();

      // Step 2: Check if the user canceled the sign-in
      if (googleUser == null) {
        // If the user cancels the sign-in, showing a cancellation message

        if(context.mounted){
          CustomSnackbar.show(
            context: context,
            label: "Sign-in canceled. Please try again.",
          );
        }

        return;
      }

      // Step 3: Getting the authentication details (idToken and accessToken)
      final googleAuth = await googleUser.authentication;



      // Step 4: Check if authentication details are available
      if (googleAuth.idToken == null || googleAuth.accessToken == null) {

        if(context.mounted){
          CustomSnackbar.show(
            context: context,
            label: "Authentication failed. Please try again.",
          );
        }

        return;
      }

      // Step 5: Create Firebase credential using the Google authentication details
      final googleCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // Step 6: Sign in with the Google credential
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(googleCredential);

      await userCredential.user!.updateDisplayName(googleUser.displayName);
      await userCredential.user!.reload();

      // Step 7: Handle successful sign-in and navigate to home page or show a success message
      String? fullName = userCredential.user?.displayName;
      String lastName = "";

      if (fullName != null && fullName.isNotEmpty) {
        List<String> nameParts = fullName.split(' ');
        if (nameParts.isNotEmpty) {
          lastName = nameParts.last;
        }
      }

      // Check if the context is still mounted before navigating or showing UI
      if (context.mounted) {
        CustomAlertBox().showCustomAnimatedAlert(
          context: context,
          title: "🎉 Welcome, $lastName!",
          label: "Your account is successfully created using Google.",
          userCred: userCredential,
        );
      }

    } on FirebaseAuthException catch (e) {
      // Step 8: Handle FirebaseAuth exceptions and show error messages
      String errorMessage = getFirebaseErrorMessage(e.code);

      if (context.mounted) {
        CustomSnackbar.show(
          context: context,
          label: errorMessage,
        );
      }
    }
  }







}
