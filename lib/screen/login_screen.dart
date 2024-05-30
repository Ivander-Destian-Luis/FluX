import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/services/authentication_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flux/services/account_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorText = '';
  bool _obscurePassword = true;
  late Account account;
  late SharedPreferences prefs;
  late ColorPallete colorPallete;
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

  Future<void> _signIn() async {
    try {
      final String userEmail = _emailController.text;
      final String password = _passwordController.text;

      if (userEmail.isNotEmpty && password.isNotEmpty) {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: userEmail,
          password: password,
        );

        _saveLoginStatus();

        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacementNamed(context, '/home_screen');
      } else {
        setState(() {
          _errorText = 'Email and password cannot be empty';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorText = 'Email or password is incorrect';
      });
    }
  }

  Future<void> _saveLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPallete.backgroundColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 200, left: 30.0, right: 30.0, bottom: 10),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Center(
                      child: Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 40,
                            color: colorPallete.fontColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextField(
                      style: TextStyle(color: colorPallete.fontColor),
                      controller: _emailController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          hintText: "Your Email",
                          hintStyle: TextStyle(color: colorPallete.fontColor),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          fillColor: colorPallete.backgroundColor),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 30.0, right: 30.0, top: 10),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextField(
                      style: TextStyle(color: colorPallete.fontColor),
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "Your Password",
                        errorText: _errorText.isNotEmpty ? _errorText : null,
                        hintStyle: TextStyle(color: colorPallete.fontColor),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        fillColor: colorPallete.backgroundColor,
                        // suffixIcon: IconButton(
                        //   onPressed: () {
                        //     setState(() {
                        //       _obscurePassword = !_obscurePassword;
                        //     });
                        //   },
                        //   icon: Icon(_obscurePassword
                        //       ? Icons.visibility_off
                        //       : Icons.visibility),
                        // ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, bottom: 10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, '/forgotPassword_screen');
                          },
                          child: Text(
                            'Forgot Password',
                            style: TextStyle(fontWeight: FontWeight.bold, color: colorPallete.fontColor),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 32.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, '/register_screen');
                          },
                          child: Text(
                            'Don\'t Have Account?',
                            style: TextStyle(fontWeight: FontWeight.bold, color: colorPallete.fontColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colorPallete.backgroundColor,
                            fixedSize: const Size(350, 50),
                            side: BorderSide(color: colorPallete.fontColor, width: 2)),
                        child: Text(
                          'Login',
                          style: TextStyle(color: colorPallete.fontColor, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
