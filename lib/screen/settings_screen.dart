import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ColorPallete colorPallete;
  late SharedPreferences prefs;

  bool? _isDarkMode;
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
      _isDarkMode = value.getBool('isDarkMode') ?? false;
      setState(() {
        _isLoading = false;
      });
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: colorPallete.backgroundColor,
            appBar: AppBar(
              title: Text(
                'Settings',
                style: TextStyle(color: colorPallete.fontColor),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: colorPallete.fontColor),
                onPressed: () {
                  Navigator.popAndPushNamed(context, '/main');
                },
              ),
              backgroundColor: colorPallete.backgroundColor,
            ),
            body: PopScope(
              canPop: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text('Dark Mode',
                            style: TextStyle(
                                color: colorPallete.fontColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ),
                      Switch(
                        value: _isDarkMode!,
                        onChanged: (value) {
                          setState(() {
                            _isDarkMode = !_isDarkMode!;
                            colorPallete = _isDarkMode!
                                ? DarkModeColorPallete()
                                : LightModeColorPallete();
                          });
                          prefs.setBool('isDarkMode', _isDarkMode!);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
