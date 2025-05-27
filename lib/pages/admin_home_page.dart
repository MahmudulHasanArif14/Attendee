import 'package:attendee/pages/settings.dart';
import 'package:attendee/widgets/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/database_helper.dart';
import '../provider/profile_image_provider.dart';
import '../widgets/custom_admin_card.dart';
import 'notification_page.dart';

class AdminHomePage extends StatefulWidget {
  final User user;
  const AdminHomePage({super.key, required this.user});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late final User userInfo;
  String fullName = "Name";
  int index = 1;
  List<Map<String, dynamic>> teamMembers = [];
  List<Map<String, dynamic>> searchMember = [];
  Map<String, dynamic> memberAttendance = {};
  final TextEditingController _searchController = TextEditingController();





  //Update Data to database
  Future<void> _updateField(
      BuildContext context,
      String key,
      String value,
      ) async {
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
    //Overlay Style
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
    widget.user.userMetadata!['phone'].toString().trim();
    _updateField(context, 'full_name', fullName);
    if (phoneNumber != 'null') {
      _updateField(context, 'phone', phoneNumber);
    }
    _updateField(context, 'email', widget.user.email!);

    // Wait until the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ///Fetch the user data
      await _fetchInitialData();

    });
  }

  Future<void> _fetchInitialData() async {
    try {
      final provider = Provider.of<DatabaseHelperProvider>(context, listen: false);
      await provider.fetchTeamMemberProfile();
      final data = provider.teamMemberList ?? [];
      final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());

      Map<String, dynamic> attendanceMap = {};
      await Future.forEach(data, (member) async {
        await provider.fetchUserAttendanceById(todayDate, member['id']);
        attendanceMap[member['id']] = provider.todayStatus;
      });

      setState(() {
        teamMembers = data;
        searchMember = List.from(data);
        memberAttendance = attendanceMap;
        print("Member Attendance list : $memberAttendance");
      });

      _searchController.addListener(_filterMembers);










    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(context: context, label: "Failed to load data :$e");
      }
    }
  }





  Future<void> _makePhoneCall(String phoneNumber) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }












  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      searchMember = teamMembers.where((member) {
        final name = (member['full_name'] ?? '').toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

















  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dbProvider = Provider.of<DatabaseHelperProvider>(context);
    final profile = dbProvider.profile;
    final todayAttendance = dbProvider.todayAttendance;
    final workingDaysCount = dbProvider.workedDaysCount ?? 0;
    final checkInTime = todayAttendance?["check_in_time"] ?? "";
    final checkOutTime = todayAttendance?["check_out_time"] ?? "";
    final breakTimeSec = todayAttendance?["totalBreakTime"] ?? 0;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 350;



    return ClipRect(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _fetchInitialData,
          child: SizedBox(
            height: double.infinity,
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
                                      radius: isSmallScreen ? 25 : 29,
                                      backgroundImage:
                                      profileProvider.cachedImageBytes !=
                                          null
                                          ? MemoryImage(
                                        profileProvider
                                            .cachedImageBytes!,
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

                            SizedBox(width: isSmallScreen ? 8 : 12),
                            //User Name and Designation
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName,
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                                      fontSize: isSmallScreen ? 12 : 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),

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
                                icon: Icon(
                                  Icons.notifications_none_rounded,
                                  size: isSmallScreen ? 24 : 26,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => NotificationScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                      ],
                    ),
                  ),

                  //   Body Part

                  // Employee Total
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
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              double gridHeight =
                              constraints.maxWidth > 600 ? 350 : 280;
                              return SizedBox(
                                height: gridHeight,
                                child: GridView.count(
                                  crossAxisCount:
                                  constraints.maxWidth > 600 ? 4 : 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio:
                                  constraints.maxWidth > 600 ? 0.9 : 1.3,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    customAdminCard(
                                      "Total Employees",
                                      CupertinoIcons.group,
                                      isDark,
                                      isSmallScreen: isSmallScreen,
                                      status: "200",

                                    ),
                                    customAdminCard(
                                      "Total Working Hours",
                                      CupertinoIcons.hammer,
                                      isDark,
                                      isSmallScreen: isSmallScreen,
                                      status: "7,3200 hrs",

                                    ),
                                    customAdminCard(
                                      "Payrolls Sent",
                                      CupertinoIcons.money_pound,
                                      isDark,
                                      isSmallScreen: isSmallScreen,
                                      status: "85/120",

                                    ),
                                    customAdminCard(
                                      "Active today",
                                      CupertinoIcons.checkmark_alt_circle,
                                      isDark,
                                      isSmallScreen: isSmallScreen,
                                      status: "85/120",
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          SizedBox(height: isSmallScreen ? 4 : 8),
                          //   Activity Part

                          SizedBox(height: isSmallScreen ? 8 : 12),

                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                                prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black54),
                                filled: true,
                                fillColor: isDark ? Colors.grey[850] : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: searchMember.isEmpty
                                ? const Center(child: Text("No team members found"))
                                : ListView.builder(
                              itemCount: searchMember.length,
                              itemBuilder: (context, index) {
                                final member = searchMember[index];
                                final attendance = memberAttendance[member['id']];
                                final userStatus = attendance?['check_in_time'];
                                final userCheckout=attendance?['check_out_time'];
                                final bool status = userStatus != null && userStatus.toString().isNotEmpty && (userCheckout==null || userCheckout.toString().isEmpty);

                                return ListTile(
                                  leading: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundImage: (member['avatar_url'] == null || member['avatar_url'].isEmpty)
                                            ? const AssetImage("assets/images/avatar.png") as ImageProvider
                                            : NetworkImage(member['avatar_url']),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color:status? Colors.green:Colors.grey,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: isDark?Colors.white54:Colors.white, width: 2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Text(member['full_name'] ?? 'Unknown'),
                                  subtitle: Text(member['designation']?.toString().trim() ?? 'Customer Support Executive'),
                                  trailing: PopupMenuButton<String>(
                                    color: Colors.grey[900],
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {},
                                    itemBuilder: (context) => [
                                      PopupMenuItem<String>(
                                        child: TextButton(
                                          onPressed: () {
                                            final String? userPhoneNo = member['phone']?.toString();
                                            if (kDebugMode) {
                                              print("User phone no is $userPhoneNo");
                                            }
                                            if (userPhoneNo != null && userPhoneNo.trim().isNotEmpty) {
                                              _makePhoneCall(userPhoneNo);
                                            } else {
                                              CustomSnackbar.show(
                                                context: context,
                                                label: "Looks like this user hasn't added a phone number yet!",
                                              );
                                            }
                                          },
                                          child: const Text(
                                            "Call Now",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
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
      ),
    );
  }
}
