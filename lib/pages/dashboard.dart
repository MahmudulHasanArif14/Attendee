import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({required this.user, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {





  DateTime today = DateTime.now().toLocal(); // Get current local time
  String fullName="Name";
  final ScrollController _scrollController = ScrollController();






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
    fullName=widget.user.displayName.toString().trim();


    // Wait until the widget is built before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int todayIndex = generatedDatesForCurrentMonth().indexWhere((date) =>
      date.day == today.day &&
          date.month == today.month &&
          date.year == today.year);

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

    return Scaffold(
      backgroundColor: Colors.blue[500],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile and Notification Icon Row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage("assets/images/avatar.png"),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Customer Support Executive",
                              style: TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.notifications_outlined,color: Colors.black,),
                          onPressed: () {
                           print( monthDates[3]);
          
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
          
                    // Scrollable Date Selector
                    SizedBox(
                      height: 62,
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
                          bool isPastDate =
                              date.year < 2021;
          
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: GestureDetector(
                              onTap:(){
                              //   On tap What to do here goes
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 11,
                                      horizontal: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isToday
                                              ? Colors.blue
                                              : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
