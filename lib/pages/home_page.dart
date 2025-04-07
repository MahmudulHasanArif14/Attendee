import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:intl/intl.dart';

import '../widgets/custom_attendance_card.dart';

class Dashboard extends StatefulWidget {
  final User user;

  const Dashboard({super.key, required this.user});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DateTime today = DateTime.now().toLocal(); // Get current local time
  String fullName = "Name";
  final ScrollController _scrollController = ScrollController();
  int index = 1;

  List events = [
    {
      "icon": Icons.login,
      "title": "Check In",
      "time": "10:00 am",
      "date": "April 17, 2023",
      "status": "On Time",
    },
    {
      "icon": Icons.logout,
      "title": "Check In",
      "time": "10:00 am",
      "date": "April 17, 2023",
      "status": "On Time",
    },
    {
      "icon": Icons.login,
      "title": "Check In",
      "time": "10:00 am",
      "date": "April 17, 2023",
      "status": "On Time",
    },
    {
      "icon": Icons.login,
      "title": "Check In",
      "time": "10:00 am",
      "date": "April 17, 2023",
      "status": "On Time",
    },
    {
      "icon": Icons.login,
      "title": "Check In",
      "time": "10:00 am",
      "date": "April 17, 2023",
      "status": "On Time",
    },
    {
      "icon": Icons.login,
      "title": "Check In",
      "time": "10:00 am",
      "date": "April 17, 2023",
      "status": "On Time",
    },
    {
      "icon": Icons.login,
      "title": "Check In",
      "time": "10:00 am",
      "date": "April 17, 2023",
      "status": "On Time",
    },
    {
      "icon": Icons.login,
      "title": "Check In",
      "time": "10:00 am",
      "date": "April 17, 2023",
      "status": "On Time",
    },
    {
      "icon": Icons.login,
      "title": "Check In",
      "time": "10:00 am",
      "date": "April 17, 2023",
      "status": "On Time",
    },
    {
      "icon": Icons.lunch_dining,
      "title": "Break In",
      "time": "12:30 am",
      "date": "April 17, 2023",
      "status": "On Time",
    },
  ];


  // Generate all dates of the current month
  List<DateTime> generatedDatesForCurrentMonth() {
    int year = today.year;
    int month = today.month;
    int daysInMonth = DateTime(year, month + 1, 0).day;

    // it will create a DateTime type object where will be present Datetime(year,month,date) each index
    return List.generate(
      daysInMonth,
      (index) => DateTime(year, month, index + 1),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fullName = widget.user.displayName.toString().trim();

    // Wait until the widget is built before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int todayIndex = generatedDatesForCurrentMonth().indexWhere(
        (date) =>
            date.day == today.day &&
            date.month == today.month &&
            date.year == today.year,
      );

      if (todayIndex != -1) {
        double itemWidth = 70.0;
        _scrollController.animateTo(
          todayIndex * itemWidth,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> monthDates = generatedDatesForCurrentMonth();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: ClipRect(
        child: Scaffold(
          extendBody: true,
          body: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile and Notification Icon Row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 29,
                            backgroundImage: AssetImage(
                              "assets/images/avatar.png",
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Customer Support Executive",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1.1,
                                  wordSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white60
                                        : Colors.black26,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.transparent,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.notifications_none_rounded),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Scrollable Date Selector
                      SizedBox(
                        height: 75,
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: monthDates.length,
                          itemBuilder: (context, index) {
                            DateTime date = monthDates[index];
                            bool isToday =
                                date.day == today.day &&
                                date.month == today.month &&
                                date.year == today.year;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  //   On tap What to do here goes
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 23,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isToday
                                                ? Colors.blue
                                                : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            DateFormat("dd").format(date),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  isToday
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                          ),
                                          Text(
                                            DateFormat("EEE").format(date),
                                            style: TextStyle(
                                              color:
                                                  isToday
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      //   END HERE
                    ],
                  ),
                ),

                //   Body Part

                // Today Attendance
                Container(
                  padding: EdgeInsets.zero,
                  width: double.infinity,
                  height: 595,
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff202327) : Color(0xffffffff),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today Attendance",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // GridBox
                        SizedBox(
                          height: 300,
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.2,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              attendanceCard(
                                "Check In",
                                "10:20 am",
                                "On Time",
                                Icons.login,
                                isDark,
                              ),
                              attendanceCard(
                                "Check Out",
                                "07:00 pm",
                                "Go Home",
                                Icons.logout,
                                isDark,
                              ),
                              attendanceCard(
                                "Break Time",
                                "00:30 min",
                                "Avg 30 min",
                                Icons.timer,
                                isDark,
                              ),
                              attendanceCard(
                                "Total Days",
                                "28",
                                "Working Days",
                                Icons.calendar_today,
                                isDark,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10),
                        //   Activity Part

                        // Activity header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Your Activity",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const Text(
                              "View All",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff2e79e3),
                              ),
                            ),
                          ],
                        ),

                        // Activity Item And Button
                        SizedBox(
                          height: 183,
                          child: Stack(
                            children: [
                              // ListView
                              SizedBox(
                                height: 139,
                                child: ListView.builder(
                                  itemCount: events.length,
                                  itemBuilder: (context, index) {
                                    var event = events[index];
                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 12,
                                      ),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Color(0xCC000000),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Color(0x1A2196F3),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              event["icon"],
                                              color: Colors.blue,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event["title"],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  event["date"],
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                event["time"],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                event["status"],
                                                style: TextStyle(
                                                  color: Colors.greenAccent,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),

                              //  Swipe Button Positioning
                              Positioned(
                                top: 128,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: SwipeButton.expand(
                                    activeThumbColor: Colors.white,
                                    // inactiveThumbColor: Colors.blue,
                                    activeTrackColor: Color(0xff4390fd),
                                    // inactiveTrackColor: Colors.white,
                                    child: Text("Swipe to Check In"),
                                    onSwipe: () {},
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
