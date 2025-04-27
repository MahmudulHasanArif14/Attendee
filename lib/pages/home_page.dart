import 'package:attendee/helper_functions/helper_func.dart';
import 'package:attendee/pages/settings.dart';
import 'package:attendee/provider/attendance_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';
import '../database/database_helper.dart';
import '../provider/profile_image_provider.dart';
import '../widgets/custom_attendance_card.dart';

class Dashboard extends StatefulWidget {
  final User user;

  const Dashboard({super.key, required this.user});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isFinished = false;
  late final User userInfo;
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


  //Update Data to database
  Future<void> _updateField(BuildContext context, String key, String value,) async {
    await Provider.of<DatabaseHelperProvider>(
      context,
      listen: false,
    ).updateUserField(key, value);
  }



  ///INIT STATE
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    userInfo = widget.user;

    fullName = widget.user.userMetadata!['name'].toString().trim();
    final String phoneNumber =
        widget.user.userMetadata!['phoneNo'].toString().trim();
    _updateField(context, 'full_name', fullName);
    if (phoneNumber != 'null') {
      _updateField(context, 'phone', phoneNumber);
    }
    _updateField(context, 'email', phoneNumber);

    // Wait until the widget is built before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_)  {
      ///Fetch the user data
      final today = DateTime.now().toUtc();
      final todayDate = DateFormat('yyyy-MM-dd').format(today);

      final provider = context.watch<DatabaseHelperProvider>();
      provider.fetchUserProfile();
      provider.fetchUserAttendanceByDate(todayDate);
      provider.getDaysWorkedInMonth(widget.user.id,DateTime.now());
      int todayIndex = generatedDatesForCurrentMonth().indexWhere(
        (date) =>
            date.day == today.day &&
            date.month == today.month &&
            date.year == today.year,
      );

      if (todayIndex != -1) {
        double itemWidth = 75 + 11.2;
        _scrollController.animateTo(
          todayIndex * itemWidth,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }






  String formatTime(String timeString) {
    if (timeString.trim().isEmpty) return '';

    final parsedTime = DateTime.parse(timeString);
    final formattedTime = DateFormat.jm().format(parsedTime.toLocal());
    return formattedTime;
  }


  String formatDuration(int totalSeconds) {
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours : $minutes min';
  }





  ///checkIn Functionality
  void checkIn() {
    HelperFunction().handleCheckIn(context);
  }

  bool isOnTime=false;
  @override
  Widget build(BuildContext context) {
    List<DateTime> monthDates = generatedDatesForCurrentMonth();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dbProvider = Provider.of<DatabaseHelperProvider>(context,listen: false);
    final profile = dbProvider.profile;
    final todayAttendance=dbProvider.todayAttendance;
    final workingDaysCount=dbProvider.workedDaysCount ?? 0;
    final checkInTime = todayAttendance?["check_in_time"] ?? "";
    final checkOutTime = todayAttendance?["check_out_time"] ?? "";
    final formattedCheckInTime = formatTime(checkInTime) ;
    final formattedCheckOutTime = formatTime(checkOutTime);
    final breakTimeSec = todayAttendance?["totalBreakTime"] ?? 0;

    final breakCount = (todayAttendance?["breakCount"] == null || todayAttendance?["breakCount"] == 0)
        ? 1
        : todayAttendance?["breakCount"];

    final avgBreakTime = formatDuration(breakTimeSec ~/ breakCount);



    final breakTime=formatDuration(breakTimeSec);

    final shiftStart=profile?["start_time"] ?? " ";



    if (checkInTime.isNotEmpty && shiftStart.isNotEmpty) {
      final checkedTimestamp = DateTime.parse(checkInTime).toLocal();
      final now = DateTime.now();

      final shiftParts = shiftStart.split(":");
      final shiftDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(shiftParts[0]),
        int.parse(shiftParts[1]),
        int.parse(shiftParts[2]),
      );

      final difference = checkedTimestamp.difference(shiftDateTime);

      print(difference);
      if (difference.isNegative || difference.inMinutes == 0) {
        print("On time ✅");
        isOnTime = true;
      } else {
        print("Late by ${difference.inMinutes.abs()} minutes ❌");
        isOnTime = false;
      }
    }


    return ClipRect(
      child: Scaffold(
        body: SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
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
                          //Profile Picture
                          Consumer<ProfileImageProvider>(
                            builder: (ctx, profileProvider, child) {
                              final imageUrl = profileProvider.imageUrl;
                              return InkWell(
                                onTap: () {
                                  // Navigate to Settings Page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              SettingPage(user: userInfo),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: 'profile-image-hero',
                                  child: CircleAvatar(
                                    radius: 29,
                                    backgroundImage:
                                        profileProvider.cachedImageBytes != null
                                            ? MemoryImage(
                                              profileProvider.cachedImageBytes!,
                                            )
                                            : (imageUrl != null
                                                ? NetworkImage(imageUrl)
                                                : const AssetImage(
                                                      "assets/images/avatar.png",
                                                    )
                                                    as ImageProvider),
                                  ),
                                ),
                              );
                            },
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
                                (profile?["designation"] != null &&
                                        profile?["designation"] != "")
                                    ? profile!["designation"]
                                    : "Customer Support Executive",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1.3,
                                  wordSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),

                          //Notification Icon
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
                  height: 605,
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
                          height: 280,
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.3,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              attendanceCard(
                                "Check In",
                                (formattedCheckInTime!= " ")?formattedCheckInTime : "No Entry",
                                isOnTime?"On Time":"Late Check-In",
                                Icons.login,
                                isDark,
                              ),
                              attendanceCard(
                                "Check Out",
                                (formattedCheckOutTime!= " ")?formattedCheckOutTime : "No Entry",
                                "Go Home",
                                Icons.logout,
                                isDark,
                              ),
                              attendanceCard(
                                "Break Time",
                                 breakTime,
                                "Avg $avgBreakTime",
                                Icons.timer,
                                isDark,
                              ),
                              attendanceCard(
                                "Total Days",
                                "$workingDaysCount",
                                "Working Days",
                                Icons.calendar_today,
                                isDark,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 5),
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
                        Column(
                          children: [
                            // ListView
                            SizedBox(
                              height: 128,
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
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
                            IntrinsicHeight(
                              child: Center(
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: SwipeableButtonView(
                                    buttonText:
                                        context.read<AttendanceProvider>().isCheckedIn
                                            ? "Swipe to Check Out"
                                            : "Swipe to Check In",
                                    buttonWidget: AnimatedSwitcher(
                                      duration: Duration(milliseconds: 250),
                                      child: Icon(
                                        CupertinoIcons.chevron_forward,
                                        key: ValueKey(
                                          context.read<AttendanceProvider>().isCheckedIn,
                                        ),
                                        color: Colors.blue,
                                      ),
                                    ),

                                    activeColor:
                                    context.read<AttendanceProvider>().isCheckedIn
                                            ? Colors.redAccent
                                            : Color(0xff4390fd),
                                    isFinished: isFinished,
                                    onWaitingProcess: () {
                                      setState(() {
                                        isFinished = true;
                                      });
                                    },
                                    onFinish: () async {
                                      if (!context.read<AttendanceProvider>().isCheckedIn) {
                                        ///CheckedIn the user
                                        checkIn();
                                      } else {
                                        ///CheckOut the user here
                                         await HelperFunction().handleCheckOut(
                                          context,
                                        );


                                      }

                                      setState(() {
                                        isFinished = false;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
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
