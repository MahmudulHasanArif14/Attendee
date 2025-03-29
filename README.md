# 🏢 Attendee: Employee Attendance System 📍

Attendee is a cross-platform mobile application designed to track employee attendance based on their real-time location within the office. Built with Flutter and Firebase, the app provides a seamless way for employees to mark their attendance while administrators can manage office locations, monitor working hours, track attendance, and much more!

## ✨ Features
- **📍 Location-based Attendance**: Automatically tracks attendance using the employee's real-time location within the office.
- **🛠️ Admin Panel**: Admins can manage multiple office locations, monitor employee attendance, and track working hours.
- **💼 Working Hours & Salary Tracking**: Easily mark salary payments and track the working hours of employees.
- **💬 Real-Time Chat**: A chat feature that allows employees to communicate with each other or with the admin.
- **📱 Cross-Platform**: Built with Flutter to ensure the app works seamlessly on both Android and iOS.

## 🛠 Technologies Used
- **Flutter**: The UI framework for building cross-platform apps.
- **Firebase**: Used for authentication, real-time database, and notifications.
- **Google Maps API**: For tracking employee locations within the office.

## 📦 Installation

### ⚙️ Prerequisites
1. [Install Flutter](https://flutter.dev/docs/get-started/install)
2. Set up a [Firebase account](https://firebase.google.com/) and create a Firebase project.
3. Obtain a Google Maps API key for location services.

### 🏃‍♂️ Steps to Run the App

1. **Clone the repository**:
   ```bash
   git clone https://github.com/MahmudulHasanArif14/Attende.git
   ```

2. **Navigate into the project directory**:
   ```bash
   cd Attende
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Set up Firebase**:
    - Add your Firebase project credentials:
        - **For Android**, place `google-services.json` inside:
          ```
          android/app/google-services.json
          ```
        - **For iOS**, place `GoogleService-Info.plist` inside:
          ```
          ios/Runner/GoogleService-Info.plist
          ```
    - Follow [Firebase setup documentation](https://firebase.flutter.dev/docs/overview) to integrate Firebase into both Android and iOS.

5. **Run the app**:
   ```bash
   flutter run
   ```

## 🔥 Firebase Setup
To enable authentication, database, and cloud services, you need to integrate Firebase into the app.

### Steps to Set Up Firebase

1. **Create a Firebase Project**
    - Go to [Firebase Console](https://console.firebase.google.com/).
    - Click on **Add Project** and follow the setup process.

2. **Add Firebase to Your Flutter App**
    - Follow the official guide: [Add Firebase to your Flutter app](https://firebase.flutter.dev/docs/overview)

3. **Download Firebase Configuration Files**
    - For **Android**, download `google-services.json` and place it inside:
      ```
      android/app/google-services.json
      ```
    - For **iOS**, download `GoogleService-Info.plist` and place it inside:
      ```
      ios/Runner/GoogleService-Info.plist
      ```

4. **Enable Firebase Services**
    - In the Firebase Console, enable the services you need:
        - **Authentication** (Email/Password, Google Sign-In, etc.)
        - **Firestore Database** (for storing attendance records)
        - **Cloud Messaging** (for notifications)

5. **Install Firebase Dependencies in Flutter**  
   Run the following command to install required Firebase packages:
   ```bash
   flutter pub add firebase_core firebase_auth cloud_firestore
   ```
   Then, update dependencies:
   ```bash
   flutter pub get
   ```

6. **Initialize Firebase in Your App**  
   Add the following code to `main.dart`:
   ```dart
   import 'package:firebase_core/firebase_core.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     runApp(MyApp());
   }
   ```

✅ Now Firebase is successfully integrated into your Flutter app!

## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing
Contributions are welcome! Feel free to fork this repo and submit a pull request.

## 📩 Contact
For any queries, contact [Mahmudul Hasan Arif](https://github.com/MahmudulHasanArif14).

---
Made with ❤️ using Flutter & Firebase 🚀
