import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaunchAppScreen extends StatefulWidget {
  const LaunchAppScreen({super.key});
  @override
  State<LaunchAppScreen> createState() => _LaunchAppScreenState();
}

class _LaunchAppScreenState extends State<LaunchAppScreen> {
  late SharedPreferences prefs;
  late ColorPallete colorPallete;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    prefs = await SharedPreferences.getInstance().then((value) {
      colorPallete = value.getBool('isDarkMode') ?? false
          ? DarkModeColorPallete()
          : LightModeColorPallete();
      setState(() {
        _isLoading = false;
      });
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2)).then(
      (value) {
        if (FirebaseAuth.instance.currentUser != null) {
          Navigator.popAndPushNamed(context, '/main');
        } else {
          Navigator.popAndPushNamed(context, '/login');
        }
      },
    );

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: colorPallete.backgroundColor,
            body: Center(
              child: Image(image: colorPallete.logo),
            ),
          );
  }
}
