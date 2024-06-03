import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flux/firebase_options.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flux/screen/browse_screen.dart';
import 'package:flux/screen/change_password_screen.dart';
import 'package:flux/screen/forgotPassword_screen.dart';
import 'package:flux/screen/home_screen.dart';
import 'package:flux/screen/input_data_screen.dart';
import 'package:flux/screen/launch_app_screen.dart';
import 'package:flux/screen/login_screen.dart';
import 'package:flux/screen/main_screen.dart';
import 'package:flux/screen/notification_screen.dart';
import 'package:flux/screen/posting_screen.dart';
import 'package:flux/screen/register_screen.dart';
import 'package:flux/screen/saved_screen.dart';
import 'package:flux/screen/settings_screen.dart';
import 'package:flux/screen/verification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPreferences.getInstance();
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await FlutterConfig.loadEnvVariables();
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/launch',
      theme:
          ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.black)),
      routes: {
        '/browse': (context) => const BrowseScreen(),
        '/forgotPassword': (context) => const ForgotPassword(),
        '/home': (context) => const HomeScreen(),
        'changePassword': (context) => const ChangePasswordScreen(),
        '/login': (context) => const LoginScreen(),
        '/notification': (context) => const NotificationScreen(),
        '/posting': (context) => const PostingScreen(),
        '/register': (context) => const RegisterScreen(),
        '/saved': (context) => const SavedScreen(),
        '/input_data': (context) => const InputDataScreen(),
        // '/main': (context) => const MainScreen(index: 0),
        '/launch': (context) => const LaunchAppScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/verification': (context) => const VerificationScreen(),
      },
      themeAnimationDuration: Duration.zero,
    );
  }
}
