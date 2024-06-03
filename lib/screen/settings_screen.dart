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
                            )),
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
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text('Change Password',
                            style: TextStyle(
                              color: colorPallete.fontColor,
                              fontSize: 20,
                            )),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/verification');
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                              color: colorPallete.buttonColor,
                              borderRadius: BorderRadius.circular(15)),
                          child: Text('here',
                              style:
                                  TextStyle(color: colorPallete.textLinkColor)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
  }
}
