// Custom Attendance Card
import 'package:flutter/material.dart';

Widget attendanceCard(
    String title,
    String time,
    String status,
    IconData iconData,
    bool isDark,
    ) {
  return Container(
    decoration: BoxDecoration(
      color: isDark ? Color(0xff101317) : Color(0xfff8f8f8),
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.all(15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color:isDark? Color(0x57194BAF): Color(0x47ffffff),
              ),
              child:  Center(child: Icon(iconData, color: Colors.blueAccent, size: 26)),
            ),


            const SizedBox(width: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),
        Text(
          time,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          status,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}