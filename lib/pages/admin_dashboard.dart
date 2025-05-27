import 'package:attendee/pages/profile.dart';
import 'package:attendee/pages/settings.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_home_page.dart';
import 'break_time_page.dart';
import 'home_page.dart';

class AdminDashboard extends StatefulWidget {
  final User user;
  const AdminDashboard({required this.user, super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  late final User user;
  late List<Widget> screens;
  int index = 0;

  // Bottom Navigator bar icons
  List<Widget> items = <Widget>[
    Icon(Icons.home_outlined),
    Icon(Icons.people_alt_outlined),
    Icon(CupertinoIcons.timer_fill),
    Icon(Icons.settings),
  ];

  @override
  void initState() {
    super.initState();
    user = widget.user;
    screens = <Widget>[
      AdminHomePage(user: user,),
      ProfilePage(),
      BreakManagementPage(),
      SettingPage(user: user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: ClipRect(
        child: Scaffold(
          body: screens[index],
          bottomNavigationBar: CurvedNavigationBar(
            height: 55,
            items: items,
            index: index,
            color: Colors.blue.shade300,
            backgroundColor: index==0?(isDark ? Color(0xff202327) : Color(0xffffffff)):  Colors.transparent,
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
