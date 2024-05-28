import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/screen/browse_screen.dart';
import 'package:flux/screen/home_screen.dart';
import 'package:flux/screen/notification_screen.dart';
import 'package:flux/screen/posting_screen.dart';
import 'package:flux/screen/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // TODO: 1. Deklarasikan variabel
  int _currentIndex = 0;
  late ColorPallete colorPallete;
  late SharedPreferences prefs;
  bool _isLoading = true;

  final List<Widget> _children = [
    const HomeScreen(),
    const BrowseScreen(),
    const PostingScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  void initialize() async {
    prefs = await SharedPreferences.getInstance().then((value) async {
      colorPallete = value.getBool('isDarkMode') ?? true
          ? DarkModeColorPallete()
          : LightModeColorPallete();

      setState(() {
        _isLoading = false;
      });
      return value;
    });
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
          backgroundColor: colorPallete.backgroundColor,
          body: _children[_currentIndex],
          bottomNavigationBar: CurvedNavigationBar(
            height: 75,
            backgroundColor: colorPallete.backgroundColor,
            color: colorPallete.postBackgroundColor,
            buttonBackgroundColor: _currentIndex == 2 ? colorPallete.heroColor : colorPallete.postBackgroundColor,
            animationDuration: const Duration(milliseconds: 250),
            onTap: (index) {
              setState(() {
              _currentIndex = index;
            });
            },
            items: [
              Icon(Icons.home, color: colorPallete.borderColor),
              Icon(Icons.search, color: colorPallete.borderColor),
              Icon(Icons.create_outlined, color: colorPallete.borderColor, size: _currentIndex == 2 ? 50 : 25),
              Icon(Icons.notifications, color: colorPallete.borderColor),
              Icon(Icons.account_circle, color: colorPallete.borderColor),
            ],
          ),
    );
  }
}