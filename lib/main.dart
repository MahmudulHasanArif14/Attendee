    import 'package:attendee/firebase_options.dart';
    import 'package:attendee/pages/splash_screen.dart';
    import 'package:attendee/services/notification_service.dart';
    import 'package:attendee/widgets/error_screen.dart';
    import 'package:firebase_auth/firebase_auth.dart';
    import 'package:firebase_core/firebase_core.dart';
    import 'package:firebase_messaging/firebase_messaging.dart';
    import 'package:flutter/foundation.dart';
    import 'package:flutter/material.dart';
    import 'package:flutter_dotenv/flutter_dotenv.dart';
    import 'package:supabase_flutter/supabase_flutter.dart';

    import 'helper_functions/helper_func.dart';

    @pragma('vm:entry-point')
    Future<void> msgHandler(RemoteMessage msg) async{
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }

    void main() async{
      WidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: ".env");

      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      FirebaseMessaging.onBackgroundMessage(msgHandler);
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL'] ?? '',
        anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      );
      runApp(const MyApp());
    }


    class MyApp extends StatefulWidget {
      const MyApp({super.key});

      @override
      State<MyApp> createState() => _MyAppState();
    }

    class _MyAppState extends State<MyApp> {

      @override
      void initState() {
        // TODO: implement initState
        super.initState();
        NotificationServices().initNotificationService(context);
      }

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

