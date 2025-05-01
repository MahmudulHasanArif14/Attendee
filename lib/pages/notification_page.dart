import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: Hero(
        tag: "View All",
        child: ListView(
          children: const [
            NotificationItem(
              title: 'You update your profile picture',
              description: 'You just update your profile picture.',
              date: 'June 16th',
            ),
            Divider(height: 1),
            NotificationItem(
              title: 'Password Changed',
              description: 'You\'ve completed change the password.',
              date: 'April 13, 2023',
              time: '22:32 PM',
            ),
            Divider(height: 1),
            NotificationItem(
              title: 'Mark Alen Applied for Leave',
              description: 'Please accept my home request.',
              date: 'February 23, 2022',
              time: '21:32 PM',
            ),
            Divider(height: 1),
            NotificationItem(
              title: 'System Update',
              description: 'Please update to revert app, for get oncoring experience.',
              date: 'April 15, 2023',
              time: '21:32 PM',
            ),
            Divider(height: 1),
            NotificationItem(
              title: 'You update your profile picture',
              description: 'You just update your profile picture.',
              date: 'June 16th',
            ),
            Divider(height: 1),
            NotificationItem(
              title: 'Password Changed',
              description: 'You\'ve completed change the password.',
              date: 'April 12, 2023',
              time: '22:32 PM',
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final String? time;

  const NotificationItem({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification icon
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, size: 24),
          ),

          // Notification content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time != null ? '$date at $time' : date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

