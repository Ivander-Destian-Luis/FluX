import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flux/firebase_options.dart';
import 'package:flux/screen/browse_screen.dart';
import 'package:flux/screen/home_screen.dart';
import 'package:flux/screen/input_data_screen.dart';
import 'package:flux/screen/login_screen.dart';
import 'package:flux/screen/notification_screen.dart';
import 'package:flux/screen/posting_screen.dart';
import 'package:flux/screen/profile_screen.dart';
import 'package:flux/screen/register_screen.dart';
import 'package:flux/screen/saved_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPreferences.getInstance();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfileScreen(),
      initialRoute: '/',
      routes: {
        '/browse_screen': (context) => const BrowseScreen(),
        '/home_screen': (context) => const HomeScreen(),
        '/login_screen': (context) => const LoginScreen(),
        '/notification_screen': (context) => const NotificationScreen(),
        '/posting_screen': (context) => const PostingScreen(),
        '/profile_screen': (context) => const ProfileScreen(),
        '/register_screen': (context) => const RegisterScreen(),
        '/saved_screen': (context) => const SavedScreen(),
        '/input_data_screen': (context) => const InputDataScreen()
      },
    );
  }
}
