  import 'package:attendee/firebase_options.dart';
import 'package:attendee/pages/splash_screen.dart';
import 'package:attendee/widgets/error_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'helper_functions/helper_func.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Western Car',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: kIsWeb ? 'Arial' : null,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: kIsWeb ? 'Arial' : null,
      ),


      home: FutureBuilder(
        future: HelperFunction().initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Splashscreen();
          } else if (snapshot.hasError) {
            return ErrorScreen(errorMessage: snapshot.error.toString());
          } else {
            return const Splashscreen();
          }
        },
      ),
    );
  }
}

