import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserCredential usercred;

   HomePage({required this.usercred, super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HomePage"),
      ),
      body: Center(
        child:Column(
          children: [
            Text(widget.usercred.user.toString()),
            Text(widget.usercred.additionalUserInfo!.profile.toString()),
            Text("Welcome, ${widget.usercred.user?.email ?? 'User'}"),


    ],
        ),
      ),
    );
  }
}
