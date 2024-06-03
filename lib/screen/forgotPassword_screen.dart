import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/screen/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _previousPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _errorText = '';
  late Account account;
  late ColorPallete colorPallete;
  late SharedPreferences prefs;
  bool _obscurePassword = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

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

  void passwordValidation() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.length < 8 ||
        !newPassword.contains(RegExp(r'[A-Z]')) ||
        !newPassword.contains(RegExp(r'[a-z]')) ||
        !newPassword.contains(RegExp(r'[0-9]'))) {
      setState(() {
        _errorText = 'Minimal 8 Karakter, kombinasi [A-Z], [a-z], [0-9]';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorText = 'Password baru dan konfirmasi password tidak cocok';
      });
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        setState(() {
          _errorText = 'Failed to update password: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: colorPallete.backgroundColor,
            body: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 150, left: 30.0, right: 30.0, bottom: 10),
                          child: Text('Previous Password',
                              style: TextStyle(
                                  fontSize: 16, color: colorPallete.fontColor)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: TextFormField(
                            controller: _previousPasswordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(color: colorPallete.fontColor),
                            decoration: InputDecoration(
                              errorText:
                                  _errorText.isNotEmpty ? _errorText : null,
                              border: const UnderlineInputBorder(
                                  borderSide: BorderSide()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 30.0, left: 30.0, right: 30.0, bottom: 10),
                          child: Text('New Password',
                              style: TextStyle(
                                  fontSize: 16, color: colorPallete.fontColor)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: TextFormField(
                            controller: _newPasswordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(color: colorPallete.fontColor),
                            decoration: InputDecoration(
                              errorText:
                                  _errorText.isNotEmpty ? _errorText : null,
                              border: const UnderlineInputBorder(
                                  borderSide: BorderSide()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 30.0, right: 30.0, top: 20, bottom: 10),
                          child: Text('Confirm Password',
                              style: TextStyle(
                                  fontSize: 16, color: colorPallete.fontColor)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 30, right: 30, bottom: 20),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            style: TextStyle(color: colorPallete.fontColor),
                            decoration: InputDecoration(
                              errorText:
                                  _errorText.isNotEmpty ? _errorText : null,
                              border: const UnderlineInputBorder(
                                  borderSide: BorderSide()),
                            ),
                            obscureText: _obscurePassword,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              passwordValidation();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: colorPallete.backgroundColor),
                            child: Text(
                              'Change It',
                              style: TextStyle(color: colorPallete.fontColor),
                            )),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
