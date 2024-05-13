import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:isi_student/api/firebase_api.dart';
import 'package:isi_student/firebase_options.dart';
import 'package:isi_student/splash_screen/splash_screen.dart';
import 'package:isi_student/student_auth/home.dart';
import 'package:isi_student/student_auth/login.dart';
import 'package:isi_student/student_auth/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase notifications
  FirebaseApi().initNotifications();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ISI App',
      initialRoute: '/',
      routes: {
        '/': (context) => AnimatedSplashScreen(
              duration: 4000, // Adjust duration as needed
              splash: Image.asset(
                'assets/logo.png', // Change to your image file path
                height: 100,
                width: 100,
              ),
              nextScreen: SplashScreen(),
              splashTransition:
                  SplashTransition.fadeTransition, // Choose your transition
              backgroundColor: Colors.white, // Set background color
            ),
        '/login': (context) => const Login(),
        '/home': (context) => const Home(),
      },
    );
  }
}
