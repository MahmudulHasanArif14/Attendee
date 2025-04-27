import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black87
                          : Colors.white70,
                    ),
                    children: [
                      _sectionTitle("🔐 Last Updated: April 19, 2025\n\n", context),
                      _normalText("This Privacy Policy explains how Attendee collects, uses, and protects your personal information when you use our app.\n\n"),

                      _sectionTitle("📸 1. Profile Image Access\n", context),
                      _bulletPoint("We request permission to access your device’s gallery."),
                      _bulletPoint("Your selected profile image is stored securely for identification within the app."),
                      _bulletPoint("We do not share your profile image with any third-party services."),

                      _sectionTitle("\n📍 2. Location Data\n", context),
                      _bulletPoint("We collect location data for attendance tracking purposes only."),
                      _bulletPoint("Location access is granted through user permission and used only during work hours."),
                      _bulletPoint("Your location data is never shared externally and is encrypted during storage."),

                      _sectionTitle("\n📞 3. Calling Access\n", context),
                      _bulletPoint("We may request call permission to facilitate direct contact between admins and employees."),
                      _bulletPoint("No call logs or contact lists are collected or stored."),
                      _bulletPoint("Calling features are limited to within-app functionality."),

                      _sectionTitle("\n🔐 4. Google Sign-In\n", context),
                      _bulletPoint("We collect your Google account’s basic info (name, email, profile picture) upon sign-in."),
                      _bulletPoint("Google data is used strictly for authentication and user profile display."),
                      _bulletPoint("We do not share or sell your Google account information."),

                      _sectionTitle("\n🛡️ 5. Data Storage & Security\n", context),
                      _bulletPoint("All personal data (profile images, location, and identity) is securely stored."),
                      _bulletPoint("We use industry-standard encryption and secure storage practices."),
                      _bulletPoint("User credentials are hashed and never stored in plaintext."),

                      _sectionTitle("\n👥 6. Data Sharing\n", context),
                      _bulletPoint("Your data is only shared with authorized admins for official purposes."),
                      _bulletPoint("We do not sell, rent, or distribute personal data to any third party."),

                      _sectionTitle("\n🔄 7. Changes to This Privacy Policy\n", context),
                      _bulletPoint("We may update this policy from time to time."),
                      _bulletPoint("Users will be notified about significant changes."),

                      _normalText("\nBy using Attendee, you consent to the data practices outlined in this Privacy Policy.\n\n"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Column(
                  children: [
                    Text(
                      "📩 Contact Us",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Divider(thickness: 1, color: Colors.grey.shade400),
                    SizedBox(height: 10),
                    RichText(
                      textAlign: TextAlign.center,
                      text: _contactEmail(
                        email: "mharif8484@gmail.com",
                        text: "Have Questions? Reach Out",
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

  TextSpan _sectionTitle(String text, BuildContext context) {
    return TextSpan(
      text: text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.blueAccent
            : Colors.lightBlueAccent,
      ),
    );
  }

  TextSpan _normalText(String text) {
    return TextSpan(text: text);
  }

  TextSpan _bulletPoint(String text) {
    return TextSpan(
      children: [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(Icons.circle, size: 8, color: Colors.blueAccent),
          ),
        ),
        TextSpan(
          text: "$text\n",
          style: const TextStyle(height: 1.5),
        ),
      ],
    );
  }

  TextSpan _contactEmail({required String email, required String text}) {
    return TextSpan(
      children: [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email, color: Colors.blueAccent, size: 22),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final Uri emailUri = Uri(scheme: 'mailto', path: email);
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  }
                },
                child: Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
