import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/screen/login_screen.dart';
import 'package:flux/services/authentication_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flux/services/account_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _previousPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _errorTextPrevious = '';
  String _errorTextNew = '';
  String _errorTextConfirm = '';
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
    final previousPassword = _previousPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    bool hasError = false;

    if (previousPassword.isEmpty) {
      setState(() {
        _errorTextPrevious = 'Previous Password cannot be empty';
      });
      hasError = true;
    } else {
      setState(() {
        _errorTextPrevious = '';
      });
    }

    if (newPassword.isEmpty) {
      setState(() {
        _errorTextNew = 'New Password cannot be empty';
      });
      hasError = true;
    } else {
      setState(() {
        _errorTextNew = '';
      });
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        _errorTextConfirm = 'Confirm Password cannot be empty';
      });
      hasError = true;
    } else {
      setState(() {
        _errorTextConfirm = '';
      });
    }

    if (newPassword.isNotEmpty) {
      if (newPassword.length < 8 ||
          !newPassword.contains(RegExp(r'[A-Z]')) ||
          !newPassword.contains(RegExp(r'[a-z]')) ||
          !newPassword.contains(RegExp(r'[0-9]'))) {
        setState(() {
          _errorTextNew =
              'Minimum 8 Characters, combination [A-Z], [a-z], [0-9]';
        });
        hasError = true;
      } else {
        setState(() {
          _errorTextNew = '';
        });
      }

      if (newPassword == previousPassword) {
        setState(() {
          _errorTextNew = 'New Password cannot be the same as Previous Password';
        });
        hasError = true;
      }

      if (confirmPassword.isNotEmpty) {
        if (confirmPassword.length < 8 ||
            !confirmPassword.contains(RegExp(r'[A-Z]')) ||
            !confirmPassword.contains(RegExp(r'[a-z]')) ||
            !confirmPassword.contains(RegExp(r'[0-9]'))) {
          setState(() {
            _errorTextConfirm =
                'Minimum 8 Characters, combination [A-Z], [a-z], [0-9]';
          });
          hasError = true;
        } else {
          setState(() {
            _errorTextConfirm = '';
          });
        }
      }

      if (confirmPassword.isNotEmpty && newPassword != confirmPassword) {
        setState(() {
          _errorTextConfirm = 'New password and confirm password do not match';
        });
        hasError = true;
      } else {
        setState(() {
          _errorTextConfirm = '';
        });
      }
    }

    if (previousPassword.isNotEmpty) {
      if (previousPassword.length < 8 ||
          !previousPassword.contains(RegExp(r'[A-Z]')) ||
          !previousPassword.contains(RegExp(r'[a-z]')) ||
          !previousPassword.contains(RegExp(r'[0-9]'))) {
        setState(() {
          _errorTextPrevious =
              'Minimum 8 Characters, combination [A-Z], [a-z], [0-9]';
        });
        hasError = true;
      } else {
        setState(() {
          _errorTextPrevious = '';
        });
      }
    }

    if (hasError) {
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: previousPassword,
        );

        await user.reauthenticateWithCredential(credential);

        await user.updatePassword(newPassword);
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, '/login_screen');
      }
    } catch (e) {
      setState(() {
        _errorTextConfirm = 'The previous password you entered was incorrect';
      });
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        color: colorPallete.fontColor,
                        size: 40,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 150, left: 30.0, right: 30.0),
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
                              errorText: _errorTextPrevious.isNotEmpty
                                  ? _errorTextPrevious
                                  : null,
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
                          padding: EdgeInsets.only(
                              top: 30.0, left: 30.0, right: 30.0),
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
                              errorText: _errorTextNew.isNotEmpty
                                  ? _errorTextNew
                                  : null,
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
                          padding: EdgeInsets.only(
                              left: 30.0, right: 30.0, top: 20.0),
                          child: Text('Confirm Password',
                              style: TextStyle(
                                  fontSize: 16, color: colorPallete.fontColor)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 30, right: 30, bottom: 30),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            style: TextStyle(color: colorPallete.fontColor),
                            decoration: InputDecoration(
                              errorText: _errorTextConfirm.isNotEmpty
                                  ? _errorTextConfirm
                                  : null,
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
                                backgroundColor: colorPallete.backgroundColor,
                                fixedSize: const Size(350, 50),
                                side: BorderSide(
                                    color: colorPallete.fontColor, width: 2)),
                            child: Text(
                              'Change It',
                              style: TextStyle(
                                  color: colorPallete.fontColor, fontSize: 20),
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
