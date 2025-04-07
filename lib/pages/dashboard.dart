import 'package:attendee/pages/profile.dart';
import 'package:attendee/pages/settings.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'home_page.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({required this.user, super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final User user;
  late List<Widget> screens;
  int index = 2;

  // Bottom Navigator bar icons
  List<Widget> items = <Widget>[
    Icon(Icons.home_outlined),
    Icon(Icons.people_alt_outlined),
    Icon(Icons.chat_outlined),
    Icon(Icons.settings),
  ];

  @override
  void initState() {
    super.initState();
    user = widget.user;
    screens = <Widget>[Dashboard(user: user), ProfilePage(),ChatPage(),SettingPage()];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRect(
        child: Scaffold(
          body: screens[index],
          bottomNavigationBar: CurvedNavigationBar(
            height: 65,
            items: items,
            index: index,
            color: Colors.blue.shade300,
            backgroundColor: Colors.transparent,
            onTap: (index) {
              setState(() {
                this.index = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
